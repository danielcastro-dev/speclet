#!/bin/bash
# speclet.sh - Autonomous Speclet loop runner
# Inspired by snarktank/ralph
#
# Usage: ./speclet.sh [max_iterations]
# Default: 10 iterations

# Don't use set -e globally - we handle errors manually for fallback
set -o pipefail

MAX_ITERATIONS=${1:-10}
SPEC_FILE=".speclet/spec.json"
PROGRESS_FILE=".speclet/progress.md"
ARCHIVE_DIR=".speclet/archive"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Model fallback configuration
# Order: Premium → Antigravity → Codex → Free fallbacks
MODELS=(
    "github-copilot/claude-opus-4.5"
    "google/antigravity-claude-opus-4-5-thinking-medium"
    "openai/gpt-5.2-codex"
    "opencode/glm-4.7-free"
    "opencode/minimax-m2.1-free"
)
MAX_RETRIES=3
CURRENT_MODEL_IDX=0

# Check dependencies
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

# Check if spec.json exists
check_spec() {
    if [[ ! -f "$SPEC_FILE" ]]; then
        echo -e "${RED}Error: $SPEC_FILE not found${NC}"
        echo -e "${YELLOW}Create a spec first:${NC}"
        echo "  1. Use the speclet-draft skill for [your feature]"
        echo "  2. Use the speclet-spec skill"
        exit 1
    fi
}

# Get feature info from spec
get_feature_info() {
    FEATURE_NAME=$(jq -r '.feature' "$SPEC_FILE")
    BRANCH_NAME=$(jq -r '.branch' "$SPEC_FILE")
    echo -e "${BLUE}Feature:${NC} $FEATURE_NAME"
    echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
}

# Count stories
count_stories() {
    TOTAL=$(jq '.stories | length' "$SPEC_FILE")
    PASSING=$(jq '[.stories[] | select(.passes == true)] | length' "$SPEC_FILE")
    REMAINING=$((TOTAL - PASSING))
    echo -e "${BLUE}Stories:${NC} $PASSING/$TOTAL complete ($REMAINING remaining)"
}

# Check if all stories pass
all_complete() {
    REMAINING=$(jq '[.stories[] | select(.passes == false)] | length' "$SPEC_FILE")
    [[ "$REMAINING" -eq 0 ]]
}

# Get next story to work on
get_next_story() {
    jq -r '[.stories[] | select(.passes == false)] | sort_by(.priority) | .[0] | "\(.id): \(.title)"' "$SPEC_FILE"
}

# Ensure correct branch
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

# Display current model info
show_model_info() {
    local model="${MODELS[$CURRENT_MODEL_IDX]}"
    local total=${#MODELS[@]}
    echo -e "${CYAN}Model:${NC} $model (${CURRENT_MODEL_IDX}/${total})"
}

# Run opencode with retry and model fallback
run_opencode_with_fallback() {
    local retries=0
    local delay=5
    
    while true; do
        local model="${MODELS[$CURRENT_MODEL_IDX]}"
        
        echo -e "${CYAN}Using model:${NC} $model"
        
        # Try to run opencode
        if opencode -m "$model" -p "Use the speclet-loop skill"; then
            return 0
        fi
        
        local exit_code=$?
        ((retries++))
        
        echo -e "${YELLOW}OpenCode failed (exit code: $exit_code)${NC}"
        
        # Check if we should retry with same model
        if [[ $retries -lt $MAX_RETRIES ]]; then
            echo -e "${YELLOW}Retry $retries/$MAX_RETRIES with $model (waiting ${delay}s)...${NC}"
            sleep $delay
            # Exponential backoff: 5s → 15s → 45s
            delay=$((delay * 3))
            continue
        fi
        
        # Max retries reached, try next model
        ((CURRENT_MODEL_IDX++))
        retries=0
        delay=5
        
        if [[ $CURRENT_MODEL_IDX -ge ${#MODELS[@]} ]]; then
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}All models exhausted. Tried:${NC}"
            for m in "${MODELS[@]}"; do
                echo -e "${RED}  - $m${NC}"
            done
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            return 1
        fi
        
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}Switching to fallback model: ${MODELS[$CURRENT_MODEL_IDX]}${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    done
}

# Run one iteration
run_iteration() {
    local iteration=$1
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Iteration $iteration/$MAX_ITERATIONS${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    show_model_info
    
    NEXT_STORY=$(get_next_story)
    echo -e "${BLUE}Next story:${NC} $NEXT_STORY"
    echo ""
    
    # Run opencode with fallback
    if ! run_opencode_with_fallback; then
        echo -e "${RED}Failed to run opencode with any model${NC}"
        return 2  # Special exit code for total failure
    fi
    
    # Check result
    if all_complete; then
        return 0
    else
        return 1
    fi
}

archive_spec() {
    DATE=$(date +%Y-%m-%d)
    FEATURE_SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g')
    ARCHIVE_PATH="$ARCHIVE_DIR/$DATE-$FEATURE_SLUG"
    
    echo -e "${BLUE}Archiving to:${NC} $ARCHIVE_PATH"
    mkdir -p "$ARCHIVE_PATH"
    
    [[ -f ".speclet/draft.md" ]] && mv ".speclet/draft.md" "$ARCHIVE_PATH/"
    [[ -f "$SPEC_FILE" ]] && mv "$SPEC_FILE" "$ARCHIVE_PATH/"
    [[ -f "$PROGRESS_FILE" ]] && mv "$PROGRESS_FILE" "$ARCHIVE_PATH/"
    
    echo -e "${GREEN}Archived!${NC}"
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
                    echo -e "${GREEN}Authenticated!${NC}"
                    return 0
                else
                    echo -e "${RED}Authentication failed${NC}"
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
        echo -e "${BLUE}Creating PR...${NC}"
        gh pr create --fill
    else
        echo -e "${YELLOW}Skipping PR. Create manually:${NC}"
        echo "  gh auth login"
        echo "  gh pr create --fill"
    fi
}

# Show available models
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

# Main
main() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                    SPECLET AUTONOMOUS LOOP                ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_dependencies
    check_spec
    get_feature_info
    count_stories
    show_models
    echo ""
    
    # Check if already complete
    if all_complete; then
        echo -e "${GREEN}✅ All stories already complete!${NC}"
        exit 0
    fi
    
    ensure_branch
    
    # Run iterations
    for ((i=1; i<=MAX_ITERATIONS; i++)); do
        result=0
        run_iteration $i || result=$?
        
        if [[ $result -eq 0 ]]; then
            echo ""
            echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║              ✅ COMPLETE - All stories passing!           ║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
            echo ""
            count_stories
            
            # Ask about archiving
            echo ""
            read -p "Archive spec files? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                archive_spec
            fi
            
            # Ask about PR
            echo ""
            read -p "Create PR? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                create_pr
            fi
            
            exit 0
        elif [[ $result -eq 2 ]]; then
            # All models exhausted
            echo -e "${RED}Cannot continue - all models failed${NC}"
            exit 1
        fi
        
        # Brief pause between iterations
        sleep 2
    done
    
    # Max iterations reached
    echo ""
    echo -e "${YELLOW}⚠️  Max iterations ($MAX_ITERATIONS) reached${NC}"
    count_stories
    echo -e "${YELLOW}Run again to continue: ./speclet.sh${NC}"
    exit 1
}

main "$@"
