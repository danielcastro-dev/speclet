#!/bin/bash

# Universal Speclet Installer for Linux/macOS
# Usage: bash install-universal.sh [REPO_URL] [BRANCH] [TARGET_DIR]

set -e

REPO_URL="${1:-https://github.com/danielcastro-dev/speclet.git}"
BRANCH="${2:-main}"
TARGET_DIR="${3:-.}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              SPECLET UNIVERSAL INSTALLER                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "Target: $TARGET_DIR"
echo "Repository: $REPO_URL"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Downloading Speclet from repository..."

# Check if git is available
if command -v git &> /dev/null; then
    # Clone the repository
    git clone --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR/speclet-repo" 2>/dev/null
    SOURCE_DIR="$TEMP_DIR/speclet-repo"
else
    # Fallback: Download as ZIP
    echo "Git not found, downloading as ZIP..."
    
    # Convert GitHub URL to raw archive URL
    ARCHIVE_URL=$(echo "$REPO_URL" | sed 's|\.git$||' | sed "s|https://github.com/|https://github.com/|" | awk '{print $1}')"/archive/refs/heads/$BRANCH.zip"
    ZIP_PATH="$TEMP_DIR/speclet.zip"
    
    if ! curl -sL -o "$ZIP_PATH" "$ARCHIVE_URL"; then
        echo -e "${RED}Error: Could not download repository${NC}"
        exit 1
    fi
    
    unzip -q "$ZIP_PATH" -d "$TEMP_DIR"
    SOURCE_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "speclet-*" | head -1)
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo -e "${RED}Error: Could not retrieve Speclet files${NC}"
    exit 1
fi

echo "Installing files..."

# Create directories
mkdir -p "$TARGET_DIR/.speclet/templates"
mkdir -p "$TARGET_DIR/.speclet/tickets"
mkdir -p "$TARGET_DIR/.speclet/archive"
mkdir -p "$TARGET_DIR/.opencode/skill"
mkdir -p "$TARGET_DIR/.codex/skills"

# Copy files
cp "$SOURCE_DIR/GUIDE.md" "$TARGET_DIR/.speclet/" 2>/dev/null || true
cp "$SOURCE_DIR/loop.md" "$TARGET_DIR/.speclet/" 2>/dev/null || true
cp "$SOURCE_DIR/templates/"* "$TARGET_DIR/.speclet/templates/" 2>/dev/null || true

# Copy skills from both locations
cp -r "$SOURCE_DIR/skills/"* "$TARGET_DIR/.opencode/skill/" 2>/dev/null || true
cp -r "$SOURCE_DIR/.codex/skills/"* "$TARGET_DIR/.codex/skills/" 2>/dev/null || true

cp "$SOURCE_DIR/speclet.sh" "$TARGET_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/speclet.ps1" "$TARGET_DIR/" 2>/dev/null || true

# Make scripts executable
chmod +x "$TARGET_DIR/speclet.sh" 2>/dev/null || true

# Create DECISIONS.md if not exists
if [[ ! -f "$TARGET_DIR/.speclet/DECISIONS.md" ]]; then
    cat > "$TARGET_DIR/.speclet/DECISIONS.md" << 'EOF'
# Architecture Decisions

> Permanent file. Do NOT move to archive.

---
EOF
fi

# Update .gitignore
GITIGNORE="$TARGET_DIR/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if ! grep -q "\.speclet/" "$GITIGNORE"; then
        {
            echo ""
            echo "# Speclet"
            echo ".speclet/*"
            echo "!.speclet/DECISIONS.md"
        } >> "$GITIGNORE"
    fi
else
    cat > "$GITIGNORE" << 'EOF'
# Speclet
.speclet/*
!.speclet/DECISIONS.md
EOF
fi

echo -e "${BLUE}✓ Installed:${NC}"
echo "  .speclet/GUIDE.md"
echo "  .speclet/loop.md"
echo "  .speclet/DECISIONS.md"
echo "  .speclet/templates/*"
echo "  .opencode/skill/*"
echo "  .codex/skills/*"
echo "  ./speclet.sh"
echo "  ./speclet.ps1"
echo ""
echo -e "${GREEN}Ready! Usage:${NC}"
echo "  Use the speclet-draft skill for [feature]"
echo "  Use the speclet-spec skill"
echo "  Use the speclet-council skill"
echo ""
echo "  Or autonomous: ./speclet.sh"
echo ""
