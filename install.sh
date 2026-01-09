#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    SPECLET INSTALLER                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p .speclet/templates .speclet/tickets .speclet/archive
mkdir -p .opencode/skill

cp "$SCRIPT_DIR/GUIDE.md" .speclet/
cp "$SCRIPT_DIR/loop.md" .speclet/
cp "$SCRIPT_DIR/templates/"* .speclet/templates/
cp -r "$SCRIPT_DIR/skills/"* .opencode/skill/
cp "$SCRIPT_DIR/speclet.sh" ./

chmod +x speclet.sh

if [[ ! -f ".speclet/DECISIONS.md" ]]; then
    cat > .speclet/DECISIONS.md << 'EOF'
# Architecture Decisions

> Permanent file. Do NOT move to archive.

---
EOF
fi

if ! grep -q ".speclet/" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Speclet" >> .gitignore
    echo ".speclet/*" >> .gitignore
    echo "!.speclet/DECISIONS.md" >> .gitignore
fi

echo -e "${BLUE}Installed:${NC}"
echo "  .speclet/GUIDE.md"
echo "  .speclet/loop.md"
echo "  .speclet/DECISIONS.md"
echo "  .speclet/templates/*"
echo "  .opencode/skill/speclet-draft/"
echo "  .opencode/skill/speclet-spec/"
echo "  .opencode/skill/speclet-loop/"
echo "  ./speclet.sh"
echo ""
echo -e "${GREEN}Ready! Usage:${NC}"
echo "  Use the speclet-draft skill for [feature]"
echo "  Use the speclet-spec skill"
echo "  Use the speclet-loop skill"
echo ""
echo "  Or autonomous: ./speclet.sh"
