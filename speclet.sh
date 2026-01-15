#!/bin/bash
# speclet.sh - Autonomous Speclet loop runner
# Inspired by snarktank/ralph
#
# Usage: ./speclet.sh [max_iterations]
# Default: 10 iterations

set -o pipefail

MAX_ITERATIONS=${1:-10}
SPEC_FILE=".speclet/spec.json"
PROGRESS_FILE=".speclet/progress.md"
ARCHIVE_DIR=".speclet/archive"
CONFIG_FILE=".speclet/config.json"
CHECKPOINT_FILE=".speclet/checkpoint.json"
LOG_FILE=".speclet/loop.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODELS=(
    "github-copilot/claude-opus-4.5"
    "google/antigravity-claude-opus-4-5-thinking-medium"
    "openai/gpt-5.2-codex"
    "opencode/glm-4.7-free"
    "opencode/minimax-m2.1-free"
)
MAX_RETRIES=3
MAX_STORY_FAILURES=3
BUILD_COMMAND="npm run build"
VERIFY_BUILD=true
TEST_COMMAND=""
VERIFY_TESTS=false
STORY_TIMEOUT_MINUTES=30
CURRENT_MODEL_IDX=0

SESSION_START_TIME=0
BUILD_FAILURES=0
TEST_FAILURES=0
STORIES_COMPLETED=0
declare -a MODELS_USED
declare -a STORY_TIMES

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading config from $CONFIG_FILE" "$CYAN"
        
        # Load activeTicket and resolve paths
        ACTIVE_TICKET=$(jq -r '.activeTicket // empty' "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$ACTIVE_TICKET" && "$ACTIVE_TICKET" != "null" ]]; then
            log "Active Ticket: $ACTIVE_TICKET" "$CYAN"
            TICKET_DIR=".speclet/tickets/$ACTIVE_TICKET"
            SPEC_FILE="$TICKET_DIR/spec.json"
            PROGRESS_FILE="$TICKET_DIR/progress.md"
            DRAFT_FILE="$TICKET_DIR/draft.md"
        fi

        local models_json=$(jq -r '.models // empty' "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$models_json" && "$models_json" != "null" ]]; then
            readarray -t MODELS < <(jq -r '.models[]' "$CONFIG_FILE")
        fi
        
        local val
        val=$(jq -r '.maxRetries // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && MAX_RETRIES=$val
        
        val=$(jq -r '.maxStoryFailures // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && MAX_STORY_FAILURES=$val
        
        val=$(jq -r '.buildCommand // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && BUILD_COMMAND=$val
        
        val=$(jq -r '.verifyBuild // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ "$val" == "false" ]] && VERIFY_BUILD=false
        
        val=$(jq -r '.logFile // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && LOG_FILE=$val
        
        val=$(jq -r '.testCommand // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && TEST_COMMAND=$val
        
        val=$(jq -r '.verifyTests // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ "$val" == "true" ]] && VERIFY_TESTS=true
        
        val=$(jq -r '.storyTimeoutMinutes // empty' "$CONFIG_FILE" 2>/dev/null)
        [[ -n "$val" && "$val" != "null" ]] && STORY_TIMEOUT_MINUTES=$val
    fi
}

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" >> "$LOG_FILE"
    echo -e "$2$1${NC}"
}

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required. Install with: brew install jq (macOS) or apt install jq (Linux)${NC}"
        exit 1
    fi
    
    if ! command -v opencode &> /dev/null; then
        echo -e "${RED}Error: opencode CLI is required. See: https://opencode.ai${NC}"
        exit 1
    fi
}

check_spec() {
    if [[ ! -f "$SPEC_FILE" ]]; then
        echo -e "${RED}Error: $SPEC_FILE not found${NC}"
        echo -e "${YELLOW}Create a spec first:${NC}"
        echo "  1. Use the speclet-draft skill for [your feature]"
        echo "  2. Use the speclet-spec skill"
        exit 1
    fi
}

get_feature_info() {
    FEATURE_NAME=$(jq -r '.feature' "$SPEC_FILE")
    BRANCH_NAME=$(jq -r '.branch' "$SPEC_FILE")
    echo -e "${BLUE}Feature:${NC} $FEATURE_NAME"
    echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
}

count_stories() {
    TOTAL=$(jq '.stories | length' "$SPEC_FILE")
    PASSING=$(jq '[.stories[] | select(.passes == true)] | length' "$SPEC_FILE")
    BLOCKED=$(jq '[.stories[] | select(.blocked == true)] | length' "$SPEC_FILE" 2>/dev/null || echo 0)
    
    # Check for unstartable (dependency blocked)
    # Filter stories that are not passing, not blocked, have dependencies, and at least one dependency is not passing.
    UNSTARTABLE=$(jq --argfile spec "$SPEC_FILE" '
        [.stories[] | select(.passes == false and (.blocked // false) == false and (.dependsOn // [] | length > 0)) | 
        if any(.dependsOn[]; . as $dep | ($spec.stories[] | select(.id == $dep) | .passes) == false) then . else empty end] | length
    ' "$SPEC_FILE")
    
    REMAINING=$((TOTAL - PASSING - BLOCKED))
    echo -e "${BLUE}Stories:${NC} $PASSING/$TOTAL complete ($REMAINING remaining, $BLOCKED blocked, $UNSTARTABLE unstartable)"
}

all_complete() {
    local remaining=$(jq '[.stories[] | select(.passes == false and (.blocked != true))] | length' "$SPEC_FILE")
    [[ "$remaining" -eq 0 ]]
}

get_next_story() {
    # Filter for stories where passes: false AND blocked: false AND all dependencies are passes: true
    jq -r --argfile spec "$SPEC_FILE" '
        [.stories[] | select(.passes == false and (.blocked // false) == false) | 
        if (.dependsOn // [] | length > 0) then
            if all(.dependsOn[]; . as $dep | ($spec.stories[] | select(.id == $dep) | .passes) == true) then . else empty end
        else . end] 
        | sort_by(.priority) | .[0] | "\(.id)"' "$SPEC_FILE"
}

get_next_story_display() {
    jq -r --argfile spec "$SPEC_FILE" '
        [.stories[] | select(.passes == false and (.blocked // false) == false) | 
        if (.dependsOn // [] | length > 0) then
            if all(.dependsOn[]; . as $dep | ($spec.stories[] | select(.id == $dep) | .passes) == true) then . else empty end
        else . end] 
        | sort_by(.priority) | .[0] | "\(.id): \(.title)"' "$SPEC_FILE"
}

ensure_branch() {
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]]; then
        echo -e "${YELLOW}Switching to branch: $BRANCH_NAME${NC}"
        if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
            git checkout "$BRANCH_NAME"
        else
            git checkout -b "$BRANCH_NAME"
        fi
    fi
}

show_model_info() {
    local model="${MODELS[$CURRENT_MODEL_IDX]}"
    local total=${#MODELS[@]}
    echo -e "${CYAN}Model:${NC} $model ($((CURRENT_MODEL_IDX + 1))/$total)"
}

save_checkpoint() {
    local story_id=$1
    local iteration=$2
    local story_failures=$3
    
    jq -n \
        --arg story "$story_id" \
        --arg iter "$iteration" \
        --arg failures "$story_failures" \
        --arg model "$CURRENT_MODEL_IDX" \
        '{
            lastStory: $story,
            iteration: ($iter | tonumber),
            storyFailures: ($failures | tonumber),
            modelIndex: ($model | tonumber),
            timestamp: now | strftime("%Y-%m-%dT%H:%M:%SZ")
        }' > "$CHECKPOINT_FILE"
    
    log "Checkpoint saved: story=$story_id, iteration=$iteration" "$CYAN"
}

load_checkpoint() {
    if [[ -f "$CHECKPOINT_FILE" ]]; then
        echo -e "${CYAN}Found checkpoint, resuming...${NC}"
        
        local saved_model=$(jq -r '.modelIndex // 0' "$CHECKPOINT_FILE")
        CURRENT_MODEL_IDX=$saved_model
        
        local saved_iter=$(jq -r '.iteration // 1' "$CHECKPOINT_FILE")
        START_ITERATION=$saved_iter
        
        log "Resumed from checkpoint: iteration=$saved_iter, model_idx=$saved_model" "$CYAN"
        return 0
    fi
    return 1
}

clear_checkpoint() {
    [[ -f "$CHECKPOINT_FILE" ]] && rm "$CHECKPOINT_FILE"
}

mark_story_blocked() {
    local story_id=$1
    local temp_file=$(mktemp)
    
    jq --arg id "$story_id" '
        .stories = [.stories[] | if .id == $id then .blocked = true else . end]
    ' "$SPEC_FILE" > "$temp_file" && mv "$temp_file" "$SPEC_FILE"
    
    log "Story $story_id marked as BLOCKED after $MAX_STORY_FAILURES failures" "$RED"
}

verify_build() {
    if [[ "$VERIFY_BUILD" != "true" ]]; then
        return 0
    fi
    
    log "Verifying build: $BUILD_COMMAND" "$CYAN"
    
    if eval "$BUILD_COMMAND" >> "$LOG_FILE" 2>&1; then
        log "Build passed ✓" "$GREEN"
        return 0
    else
        log "Build FAILED ✗" "$RED"
        return 1
    fi
}

verify_tests() {
    if [[ "$VERIFY_TESTS" != "true" ]] || [[ -z "$TEST_COMMAND" ]]; then
        return 0
    fi
    
    log "Running tests: $TEST_COMMAND" "$CYAN"
    
    if eval "$TEST_COMMAND" >> "$LOG_FILE" 2>&1; then
        log "Tests passed ✓" "$GREEN"
        return 0
    else
        log "Tests FAILED ✗" "$RED"
        return 1
    fi
}

revert_changes() {
    local pre_hash=$1
    log "Reverting changes..." "$YELLOW"
    
    local current_hash=$(git rev-parse HEAD)
    if [[ -n "$pre_hash" && "$current_hash" != "$pre_hash" ]]; then
        log "New commit(s) detected. Performing hard reset to $pre_hash..." "$RED"
        git reset --hard "$pre_hash" >> "$LOG_FILE" 2>&1
    else
        log "No new commits. Cleaning working tree..." "$YELLOW"
        git checkout . >> "$LOG_FILE" 2>&1
        git clean -fd >> "$LOG_FILE" 2>&1
    fi
}

verify_story_completion() {
    local story_id=$1
    # Check if spec file exists (it might have been moved if completion logic ran early)
    if [[ ! -f "$SPEC_FILE" ]]; then
        log "Warning: $SPEC_FILE not found during verification. Checking archive..." "$YELLOW"
        # This is a bit complex for a simple check, but if STORY-5 runs, SPEC_FILE changes.
        return 0
    fi
    local passes=$(jq -r --arg id "$story_id" '.stories[] | select(.id == $id) | .passes' "$SPEC_FILE")
    
    if [[ "$passes" == "true" ]]; then
        log "Story $story_id marked complete ✓" "$GREEN"
        return 0
    else
        log "Story $story_id not marked complete, counting as failure" "$YELLOW"
        return 1
    fi
}

declare -A STORY_FAILURES

run_iteration() {
    local iteration=$1
    local story_start_time=$(date +%s)
    local pre_iteration_hash=$(git rev-parse HEAD)
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "Iteration $iteration/$MAX_ITERATIONS" "$GREEN"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    show_model_info
    
    local story_id=$(get_next_story)
    local story_display=$(get_next_story_display)
    
    if [[ -z "$story_id" || "$story_id" == "null" ]]; then
        log "No more stories to process" "$GREEN"
        return 0
    fi
    
    log "Next story: $story_display" "$BLUE"
    
    local current_failures=${STORY_FAILURES[$story_id]:-0}
    if [[ $current_failures -ge $MAX_STORY_FAILURES ]]; then
        log "Story $story_id has failed $current_failures times, marking as blocked" "$RED"
        mark_story_blocked "$story_id"
        return 1
    fi
    
    save_checkpoint "$story_id" "$iteration" "$current_failures"
    
    echo ""
    
    if ! run_opencode_with_fallback; then
        log "Failed to run opencode with any model" "$RED"
        return 2
    fi
    
    if ! verify_story_completion "$story_id"; then
        STORY_FAILURES[$story_id]=$((current_failures + 1))
        log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
        revert_changes "$pre_iteration_hash"
        return 1
    fi
    
    if [[ "$VERIFY_BUILD" == "true" ]]; then
        if ! verify_build; then
            log "Build failed after story implementation, reverting..." "$RED"
            revert_changes "$pre_iteration_hash"
            ((BUILD_FAILURES++))
            
            STORY_FAILURES[$story_id]=$((current_failures + 1))
            log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
            
            return 1
        fi
    fi
    
    if ! verify_tests; then
        log "Tests failed after story implementation, reverting..." "$RED"
        revert_changes "$pre_iteration_hash"
        ((TEST_FAILURES++))
        
        STORY_FAILURES[$story_id]=$((current_failures + 1))
        log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
        
        return 1
    fi
}

run_opencode_with_fallback() {
    local retries=0
    local delay=5
    local timeout_seconds=$((STORY_TIMEOUT_MINUTES * 60))
    
    while true; do
        local model="${MODELS[$CURRENT_MODEL_IDX]}"
        
        log "Using model: $model (timeout: ${STORY_TIMEOUT_MINUTES}m)" "$CYAN"
        MODELS_USED+=("$model")
        
        timeout "$timeout_seconds" opencode -m "$model" -p "Use the speclet-loop skill" 2>> "$LOG_FILE"
        local exit_code=$?
        
        if [[ $exit_code -eq 0 ]]; then
            return 0
        fi
        
        # Handle both timeout (124) and other failures through retry logic
        if [[ $exit_code -eq 124 ]]; then
            log "Story timed out after ${STORY_TIMEOUT_MINUTES} minutes" "$RED"
        else
            log "OpenCode failed (exit code: $exit_code)" "$YELLOW"
        fi
        
        ((retries++))
        
        if [[ $retries -lt $MAX_RETRIES ]]; then
            log "Retry $retries/$MAX_RETRIES with $model (waiting ${delay}s)..." "$YELLOW"
            sleep $delay
            delay=$((delay * 3))
            continue
        fi
        
        ((CURRENT_MODEL_IDX++))
        retries=0
        delay=5
        
        if [[ $CURRENT_MODEL_IDX -ge ${#MODELS[@]} ]]; then
            log "All models exhausted" "$RED"
            for m in "${MODELS[@]}"; do
                echo -e "${RED}  - $m${NC}"
            done
            return 1
        fi
        
        log "Switching to fallback model: ${MODELS[$CURRENT_MODEL_IDX]}" "$YELLOW"
    done
}

declare -A STORY_FAILURES

run_iteration() {
    local iteration=$1
    local story_start_time=$(date +%s)
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "Iteration $iteration/$MAX_ITERATIONS" "$GREEN"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    show_model_info
    
    local story_id=$(get_next_story)
    local story_display=$(get_next_story_display)
    
    if [[ -z "$story_id" || "$story_id" == "null" ]]; then
        log "No more stories to process" "$GREEN"
        return 0
    fi
    
    log "Next story: $story_display" "$BLUE"
    
    local current_failures=${STORY_FAILURES[$story_id]:-0}
    if [[ $current_failures -ge $MAX_STORY_FAILURES ]]; then
        log "Story $story_id has failed $current_failures times, marking as blocked" "$RED"
        mark_story_blocked "$story_id"
        return 1
    fi
    
    save_checkpoint "$story_id" "$iteration" "$current_failures"
    
    echo ""
    
    if ! run_opencode_with_fallback; then
        log "Failed to run opencode with any model" "$RED"
        return 2
    fi
    
    if ! verify_story_completion "$story_id"; then
        STORY_FAILURES[$story_id]=$((current_failures + 1))
        log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
        return 1
    fi
    
    if [[ "$VERIFY_BUILD" == "true" ]]; then
        if ! verify_build; then
            log "Build failed after story implementation, reverting..." "$RED"
            revert_changes
            ((BUILD_FAILURES++))
            
            STORY_FAILURES[$story_id]=$((current_failures + 1))
            log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
            
            return 1
        fi
    fi
    
    if ! verify_tests; then
        log "Tests failed after story implementation, reverting..." "$RED"
        revert_changes
        ((TEST_FAILURES++))
        
        STORY_FAILURES[$story_id]=$((current_failures + 1))
        log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
        
        return 1
    fi
    
    local story_end_time=$(date +%s)
    local story_duration=$((story_end_time - story_start_time))
    STORY_TIMES+=("$story_duration")
    ((STORIES_COMPLETED++))
    
    STORY_FAILURES[$story_id]=0
    
    if all_complete; then
        clear_checkpoint
        return 0
    else
        return 1
    fi
}

archive_spec() {
    DATE=$(date +%Y-%m-%d)
    FEATURE_SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g')
    ARCHIVE_PATH="$ARCHIVE_DIR/$DATE-$FEATURE_SLUG"
    
    log "Archiving to: $ARCHIVE_PATH" "$BLUE"
    mkdir -p "$ARCHIVE_PATH"
    
    [[ -f ".speclet/draft.md" ]] && mv ".speclet/draft.md" "$ARCHIVE_PATH/"
    [[ -f "$SPEC_FILE" ]] && mv "$SPEC_FILE" "$ARCHIVE_PATH/"
    [[ -f "$PROGRESS_FILE" ]] && mv "$PROGRESS_FILE" "$ARCHIVE_PATH/"
    [[ -f "$LOG_FILE" ]] && cp "$LOG_FILE" "$ARCHIVE_PATH/"
    
    log "Archived!" "$GREEN"
}

ensure_gh_auth() {
    if ! gh auth status &>/dev/null; then
        echo -e "${YELLOW}GitHub CLI not authenticated.${NC}"
        echo ""
        echo -e "${CYAN}Options:${NC}"
        echo "  1. Enter token manually"
        echo "  2. Skip PR creation"
        echo ""
        read -p "Choice (1/2): " -n 1 -r
        echo
        
        if [[ $REPLY == "1" ]]; then
            echo -e "${CYAN}Enter your GitHub token (ghp_...):${NC}"
            read -r GH_TOKEN
            if [[ -n "$GH_TOKEN" ]]; then
                echo "$GH_TOKEN" | gh auth login --with-token
                if gh auth status &>/dev/null; then
                    log "GitHub authenticated!" "$GREEN"
                    return 0
                else
                    log "GitHub authentication failed" "$RED"
                    return 1
                fi
            fi
        fi
        return 1
    fi
    return 0
}

create_pr() {
    if ensure_gh_auth; then
        log "Creating PR..." "$BLUE"
        gh pr create --fill
    else
        echo -e "${YELLOW}Skipping PR. Create manually:${NC}"
        echo "  gh auth login"
        echo "  gh pr create --fill"
    fi
}

show_models() {
    echo -e "${CYAN}Configured models (in fallback order):${NC}"
    for i in "${!MODELS[@]}"; do
        if [[ $i -eq 0 ]]; then
            echo -e "  ${GREEN}$i. ${MODELS[$i]} (primary)${NC}"
        elif [[ $i -lt 3 ]]; then
            echo -e "  ${YELLOW}$i. ${MODELS[$i]} (fallback)${NC}"
        else
            echo -e "  ${BLUE}$i. ${MODELS[$i]} (free)${NC}"
        fi
    done
}

show_session_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - SESSION_START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    local unique_models=($(printf '%s\n' "${MODELS_USED[@]}" | sort -u))
    local avg_time=0
    if [[ ${#STORY_TIMES[@]} -gt 0 ]]; then
        local total_time=0
        for t in "${STORY_TIMES[@]}"; do
            total_time=$((total_time + t))
        done
        avg_time=$((total_time / ${#STORY_TIMES[@]}))
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}                      SESSION SUMMARY                       ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Total time:${NC}         ${minutes}m ${seconds}s"
    echo -e "${BLUE}Stories completed:${NC}  $STORIES_COMPLETED"
    echo -e "${BLUE}Stories blocked:${NC}    $BLOCKED"
    echo -e "${BLUE}Build failures:${NC}     $BUILD_FAILURES"
    echo -e "${BLUE}Test failures:${NC}      $TEST_FAILURES"
    echo -e "${BLUE}Avg time/story:${NC}     ${avg_time}s"
    echo -e "${BLUE}Models used:${NC}"
    for m in "${unique_models[@]}"; do
        echo -e "  - $m"
    done
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

main() {
    mkdir -p "$(dirname "$LOG_FILE")"
    SESSION_START_TIME=$(date +%s)
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                    SPECLET AUTONOMOUS LOOP                ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "Session started" "$GREEN"
    
    check_dependencies
    load_config
    check_spec
    get_feature_info
    count_stories
    show_models
    echo -e "${CYAN}Build command:${NC} $BUILD_COMMAND"
    echo -e "${CYAN}Verify build:${NC} $VERIFY_BUILD"
    echo -e "${CYAN}Log file:${NC} $LOG_FILE"
    echo ""
    
    if all_complete; then
        log "All stories already complete!" "$GREEN"
        exit 0
    fi
    
    START_ITERATION=1
    load_checkpoint
    
    ensure_branch
    
    for ((i=START_ITERATION; i<=MAX_ITERATIONS; i++)); do
        result=0
        run_iteration $i || result=$?
        
        if [[ $result -eq 0 ]]; then
            echo ""
            echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║              ✅ COMPLETE - All stories passing!           ║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
            echo ""
            count_stories
            show_session_summary
            log "All stories complete!" "$GREEN"
            
            echo ""
            read -p "Archive spec files? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                archive_spec
            fi
            
            echo ""
            read -p "Create PR? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                create_pr
            fi
            
            exit 0
        elif [[ $result -eq 2 ]]; then
            log "Cannot continue - all models failed" "$RED"
            show_session_summary
            exit 1
        fi
        
        sleep 2
    done
    
    echo ""
    log "Max iterations ($MAX_ITERATIONS) reached" "$YELLOW"
    count_stories
    show_session_summary
    echo -e "${YELLOW}Run again to continue: ./speclet.sh${NC}"
    exit 1
}

main "$@"
