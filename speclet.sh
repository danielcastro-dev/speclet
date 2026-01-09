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
CURRENT_MODEL_IDX=0

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${CYAN}Loading config from $CONFIG_FILE${NC}"
        
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
    REMAINING=$((TOTAL - PASSING - BLOCKED))
    echo -e "${BLUE}Stories:${NC} $PASSING/$TOTAL complete ($REMAINING remaining, $BLOCKED blocked)"
}

all_complete() {
    local remaining=$(jq '[.stories[] | select(.passes == false and (.blocked != true))] | length' "$SPEC_FILE")
    [[ "$remaining" -eq 0 ]]
}

get_next_story() {
    jq -r '[.stories[] | select(.passes == false and (.blocked != true))] | sort_by(.priority) | .[0] | "\(.id)"' "$SPEC_FILE"
}

get_next_story_display() {
    jq -r '[.stories[] | select(.passes == false and (.blocked != true))] | sort_by(.priority) | .[0] | "\(.id): \(.title)"' "$SPEC_FILE"
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

revert_changes() {
    log "Reverting uncommitted changes..." "$YELLOW"
    git checkout . 2>/dev/null
    git clean -fd 2>/dev/null
}

run_opencode_with_fallback() {
    local retries=0
    local delay=5
    
    while true; do
        local model="${MODELS[$CURRENT_MODEL_IDX]}"
        
        log "Using model: $model" "$CYAN"
        
        if opencode -m "$model" -p "Use the speclet-loop skill" 2>> "$LOG_FILE"; then
            return 0
        fi
        
        local exit_code=$?
        ((retries++))
        
        log "OpenCode failed (exit code: $exit_code)" "$YELLOW"
        
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
    
    if [[ "$VERIFY_BUILD" == "true" ]]; then
        if ! verify_build; then
            log "Build failed after story implementation, reverting..." "$RED"
            revert_changes
            
            STORY_FAILURES[$story_id]=$((current_failures + 1))
            log "Story $story_id failure count: ${STORY_FAILURES[$story_id]}/$MAX_STORY_FAILURES" "$YELLOW"
            
            return 1
        fi
    fi
    
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

main() {
    mkdir -p "$(dirname "$LOG_FILE")"
    
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
            exit 1
        fi
        
        sleep 2
    done
    
    echo ""
    log "Max iterations ($MAX_ITERATIONS) reached" "$YELLOW"
    count_stories
    echo -e "${YELLOW}Run again to continue: ./speclet.sh${NC}"
    exit 1
}

main "$@"
