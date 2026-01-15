#!/bin/bash

# speclet-bootstrap installer (Bash)
# Installs Speclet Council agents to your environment

set -e

# --- Configuration ---
SOURCE_DIR=".opencode/agent"
GLOBAL_CONFIG_DIR="$HOME/.config/opencode/agent"
LOCAL_CONFIG_DIR=".opencode/agent"
BACKUP_DIR_BASE="agents_backup"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[speclet-bootstrap]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# --- 1. Environment Detection ---
log "Detecting environment..."
if grep -q Microsoft /proc/version; then
    ENV_TYPE="WSL"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ENV_TYPE="macOS"
else
    ENV_TYPE="Linux"
fi
log "Environment: $ENV_TYPE"

# --- 2. Check Source Files ---
if [[ ! -d "$SOURCE_DIR" ]]; then
    error "Source directory '$SOURCE_DIR' not found. Run this script from the speclet repo root."
fi

REQUIRED_AGENTS=("plan-reviewer-opus.md" "plan-reviewer-sonnet.md" "plan-reviewer-gemini.md" "plan-reviewer-gpt.md" "plan-reviewer-glm.md")
MISSING_AGENTS=0

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [[ ! -f "$SOURCE_DIR/$agent" ]]; then
        warn "Missing source template: $agent"
        MISSING_AGENTS=1
    fi
done

if [[ $MISSING_AGENTS -eq 1 ]]; then
    error "Some required agent templates are missing in '$SOURCE_DIR'. Cannot proceed."
fi

# --- 3. Path Selection ---
echo ""
echo "Select installation target:"
echo "  1) Global User Config ($GLOBAL_CONFIG_DIR) - Recommended for system-wide access"
echo "  2) Project Local Config ($LOCAL_CONFIG_DIR) - Good for project-specific overrides"
echo "  3) Custom Path"
read -p "Enter choice [1]: " CHOICE
CHOICE=${CHOICE:-1}

case "$CHOICE" in
    1) TARGET_DIR="$GLOBAL_CONFIG_DIR" ;;
    2) TARGET_DIR="$LOCAL_CONFIG_DIR" ;;
    3) read -p "Enter custom path: " TARGET_DIR ;;
    *) error "Invalid choice" ;;
esac

# Resolve ~ tilde expansion if necessary (basic)
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

log "Target directory: $TARGET_DIR"

if [[ ! -d "$TARGET_DIR" ]]; then
    read -p "Directory '$TARGET_DIR' does not exist. Create it? [Y/n] " CREATE_CONFIRM
    CREATE_CONFIRM=${CREATE_CONFIRM:-Y}
    if [[ "$CREATE_CONFIRM" =~ ^[Yy]$ ]]; then
        mkdir -p "$TARGET_DIR" || error "Failed to create directory."
    else
        error "Installation cancelled."
    fi
fi

# --- 4. Backup Logic ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${TARGET_DIR}/${BACKUP_DIR_BASE}_${TIMESTAMP}"
AGENTS_FOUND=0

# Check if any target agents already exist
for agent in "${REQUIRED_AGENTS[@]}"; do
    if [[ -f "$TARGET_DIR/$agent" ]]; then
        AGENTS_FOUND=1
        break
    fi
done

if [[ $AGENTS_FOUND -eq 1 ]]; then
    log "Existing agents detected. Creating backup..."
    mkdir -p "$BACKUP_DIR"
    for agent in "${REQUIRED_AGENTS[@]}"; do
        if [[ -f "$TARGET_DIR/$agent" ]]; then
            cp "$TARGET_DIR/$agent" "$BACKUP_DIR/"
        fi
    done
    log "Backup created at: $BACKUP_DIR"
fi

# --- 5. Installation ---
log "Installing agents..."
for agent in "${REQUIRED_AGENTS[@]}"; do
    cp "$SOURCE_DIR/$agent" "$TARGET_DIR/"
    echo "  - Installed $agent"
done

# --- 6. Validation (Conditional) ---
echo ""
if command -v opencode >/dev/null 2>&1; then
    log "Validating installation with OpenCode CLI..."
    
    # Try to list agents. Note: OpenCode might need a refresh/restart to see them depending on version.
    # We just check if the command runs successfully.
    if opencode agent list > /dev/null; then
        echo -e "${GREEN}✔ OpenCode agent list verified.${NC}"
        echo "You may need to restart OpenCode or your terminal for changes to take effect."
    else
        warn "OpenCode CLI is installed but 'agent list' failed. Please check manually."
    fi
else
    log "OpenCode CLI not found in PATH. Skipping validation."
    echo "Please ensure OpenCode is installed to use these agents."
fi

echo ""
echo -e "${GREEN}Installation Complete! 🚀${NC}"
echo "Your Speclet Council agents are ready."
