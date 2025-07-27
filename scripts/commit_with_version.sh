#!/bin/bash

# Commit with version bump script
# Usage: ./scripts/commit_with_version.sh [major|minor|patch] "commit message"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Usage: $0 [major|minor|patch] \"commit message\"${NC}"
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 major \"Breaking change: refactor inventory model\""
    echo -e "  $0 minor \"Add new barcode scanning feature\""
    echo -e "  $0 patch \"Fix crash in item editing\""
    exit 1
fi

VERSION_TYPE=$1
COMMIT_MESSAGE=$2

echo -e "${BLUE}🚀 Starting versioned commit...${NC}"

# Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${YELLOW}No changes to commit. Exiting.${NC}"
    exit 0
fi

# Show current version
echo -e "${BLUE}Current version:${NC}"
./scripts/version.sh

# Bump version
echo -e "${BLUE}📈 Bumping version ($VERSION_TYPE)...${NC}"
./scripts/version.sh $VERSION_TYPE

# Get new version for commit message
NEW_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')

# Add all changes
echo -e "${BLUE}📝 Staging changes...${NC}"
git add .

# Create versioned commit message
VERSIONED_COMMIT_MESSAGE="v$NEW_VERSION: $COMMIT_MESSAGE

Version bump: $VERSION_TYPE
- Previous: $(git log -1 --pretty=format:"%h %s")
- Changes: $COMMIT_MESSAGE"

# Commit with version
echo -e "${BLUE}💾 Committing with version $NEW_VERSION...${NC}"
git commit -m "$VERSIONED_COMMIT_MESSAGE"

echo -e "${GREEN}✅ Successfully committed v$NEW_VERSION${NC}"
echo -e "${BLUE}📋 Commit message:${NC}"
echo "$VERSIONED_COMMIT_MESSAGE"
echo -e "${BLUE}🔗 View commit: git show${NC}" 