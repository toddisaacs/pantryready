#!/bin/bash

# Version management script for PantryReady
# Usage: ./scripts/version.sh [major|minor|patch] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep "version:" pubspec.yaml | sed 's/.*+//')

echo -e "${BLUE}Current version: ${CURRENT_VERSION}+${CURRENT_BUILD}${NC}"

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 [major|minor|patch] [--dry-run]${NC}"
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 patch    # 1.0.0 -> 1.0.1"
    echo -e "  $0 minor    # 1.0.0 -> 1.1.0"
    echo -e "  $0 major    # 1.0.0 -> 2.0.0"
    echo -e "  $0 patch --dry-run  # Show what would change"
    exit 1
fi

TYPE=$1
DRY_RUN=false

if [ "$2" = "--dry-run" ]; then
    DRY_RUN=true
    echo -e "${YELLOW}DRY RUN MODE - No files will be modified${NC}"
fi

# Parse current version
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Calculate new version
case $TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}Invalid version type: $TYPE${NC}"
        echo -e "${YELLOW}Use: major, minor, or patch${NC}"
        exit 1
        ;;
esac

NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
NEW_BUILD=$((CURRENT_BUILD + 1))

echo -e "${BLUE}New version: ${NEW_VERSION}+${NEW_BUILD}${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Would update:${NC}"
    echo -e "  pubspec.yaml: version: ${CURRENT_VERSION}+${CURRENT_BUILD} -> ${NEW_VERSION}+${NEW_BUILD}"
    echo -e "  lib/constants/app_constants.dart: appVersion = '${CURRENT_VERSION}' -> '${NEW_VERSION}'"
    echo -e "  lib/constants/app_constants.dart: appBuildNumber = '${CURRENT_BUILD}' -> '${NEW_BUILD}'"
else
    echo -e "${GREEN}Updating version...${NC}"
    
    # Update pubspec.yaml
    sed -i '' "s/version: ${CURRENT_VERSION}+${CURRENT_BUILD}/version: ${NEW_VERSION}+${NEW_BUILD}/" pubspec.yaml
    
    # Update app_constants.dart
    sed -i '' "s/appVersion = '${CURRENT_VERSION}'/appVersion = '${NEW_VERSION}'/" lib/constants/app_constants.dart
    sed -i '' "s/appBuildNumber = '${CURRENT_BUILD}'/appBuildNumber = '${NEW_BUILD}'/" lib/constants/app_constants.dart
    
    echo -e "${GREEN}Version updated successfully!${NC}"
    echo -e "${BLUE}New version: ${NEW_VERSION}+${NEW_BUILD}${NC}"
    
    # Show git status
    echo -e "${YELLOW}Modified files:${NC}"
    git status --porcelain | grep -E "(pubspec.yaml|app_constants.dart)" || true
fi 