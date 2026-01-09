#!/bin/bash
# speclet.sh - Autonomous Speclet loop runner
# Inspired by snarktank/ralph
#
# Usage: ./speclet.sh [max_iterations]
# Default: 10 iterations

set -e

MAX_ITERATIONS=${1:-10}
SPEC_FILE=".speclet/spec.json"
PROGRESS_FILE=".speclet/progress.md"
ARCHIVE_DIR=".speclet/archive"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Run one iteration
run_iteration() {
    local iteration=$1
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Iteration $iteration/$MAX_ITERATIONS${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    NEXT_STORY=$(get_next_story)
    echo -e "${BLUE}Next story:${NC} $NEXT_STORY"
    echo ""
    
    # Run opencode with the loop skill
    opencode -p "Use the speclet-loop skill"
    
    # Check result
    if all_complete; then
        return 0
    else
        return 1
    fi
}

# Archive completed spec
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
    
    # Check if already complete
    if all_complete; then
        echo -e "${GREEN}✅ All stories already complete!${NC}"
        exit 0
    fi
    
    ensure_branch
    
    # Run iterations
    for ((i=1; i<=MAX_ITERATIONS; i++)); do
        if run_iteration $i; then
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
                echo -e "${BLUE}Creating PR...${NC}"
                gh pr create --fill
            fi
            
            exit 0
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
