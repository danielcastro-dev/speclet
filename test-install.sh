#!/bin/bash

# Test script for Speclet installation
# Creates a test directory and verifies installation

set -e

TEST_DIR=$(mktemp -d)
echo "Testing Speclet installation in: $TEST_DIR"

cleanup() {
    echo "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

cd "$TEST_DIR"

# Test the installer
echo "Running install-universal.sh..."
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-universal.sh" \
    "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" \
    main \
    "."

# Verify installation
echo ""
echo "Verifying installation..."

if [[ ! -f ".speclet/GUIDE.md" ]]; then
    echo "ERROR: .speclet/GUIDE.md not found"
    exit 1
fi

if [[ ! -f ".speclet/loop.md" ]]; then
    echo "ERROR: .speclet/loop.md not found"
    exit 1
fi

if [[ ! -f ".speclet/DECISIONS.md" ]]; then
    echo "ERROR: .speclet/DECISIONS.md not found"
    exit 1
fi

if [[ ! -d ".speclet/templates" ]]; then
    echo "ERROR: .speclet/templates directory not found"
    exit 1
fi

if [[ ! -d ".opencode/skill" ]]; then
    echo "ERROR: .opencode/skill directory not found"
    exit 1
fi

    if [[ ! -d ".codex/skills" ]]; then
        echo "ERROR: .codex/skills directory not found"
        exit 1
    fi
fi

echo "✓ All checks passed!"
