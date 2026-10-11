#!/bin/bash

# Git Commit & Sync Script
# Syncs local repository with remote and optionally triggers Cloud CI/CD
# Usage: ./git-sync.sh [options]
# Options:
#   --sync                  Only perform git add/commit/push (skip CI/CD prompts)
#   -m "message"            Commit message
#   -b "branch"             Branch to push to (defaults to current)
#   -t "tag"                Release tag
#   --deploy-web            Trigger web deploy
#   -h, --help              Show help

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SYNC_ONLY=false
COMMIT_MSG=""
TARGET_BRANCH=""
RELEASE_TAG=""
DEPLOY_WEB=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --sync) SYNC_ONLY=true; shift ;;
        -m|--message) COMMIT_MSG="$2"; shift; shift ;;
        -b|--branch) TARGET_BRANCH="$2"; shift; shift ;;
        -t|--tag) RELEASE_TAG="$2"; shift; shift ;;
        --deploy-web) DEPLOY_WEB="y"; shift ;;
        -h|--help|-help|-\?) 
            echo "Usage: ./git-sync.sh [options]"
            echo "  --sync          Skip CI/CD prompts (git only)"
            echo "  -m, --message   Commit message"
            echo "  -b, --branch    Target branch (defaults to current)"
            echo "  -t, --tag       Release tag (e.g. v1.0.0)"
            echo "  --deploy-web    Trigger Web Deploy"
            echo "  -v, --version   Show script version"
            exit 0
            ;;
        -v|--version)
            echo "git-sync.sh v0.3.0"
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

echo -e "${BLUE}Starting git sync...${NC}"

# 1. Branch Selection
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ -z "$TARGET_BRANCH" ]]; then
    echo -e "${YELLOW}Available local branches:${NC}"
    git branch --format="  %(refname:short)"
    echo ""
    read -p "Target branch [$current_branch]: " user_branch
    TARGET_BRANCH=${user_branch:-$current_branch}
fi

if [[ "$current_branch" != "$TARGET_BRANCH" ]]; then
    echo -e "${YELLOW}Switching to branch $TARGET_BRANCH...${NC}"
    git checkout "$TARGET_BRANCH" || git checkout -b "$TARGET_BRANCH"
fi

# 2. Stage and Commit
git add .
if [[ -n "$(git status --porcelain)" ]]; then
    if [[ -z "$COMMIT_MSG" ]]; then
        read -p "Enter commit message (leave blank for auto-timestamp): " COMMIT_MSG
    fi
    if [[ -z "$COMMIT_MSG" ]]; then
        COMMIT_MSG="$(date '+%d-%b-%Y-T-%H:%M')"
    fi
    git commit -m "$COMMIT_MSG"
else
    echo -e "${YELLOW}No changes to commit.${NC}"
fi

# 3. Fetch, Pull, Push
echo -e "${BLUE}Fetching and pulling from origin/$TARGET_BRANCH...${NC}"
git fetch origin "$TARGET_BRANCH" --tags || true
git pull --rebase origin "$TARGET_BRANCH" || true
git push origin "$TARGET_BRANCH"

echo -e "${GREEN}Git sync completed for branch '$TARGET_BRANCH'!${NC}"

if [[ "$SYNC_ONLY" == true ]]; then
    exit 0
fi

# 4. Cloud Release Pipeline Trigger (Tags)
echo -e "${YELLOW}--- Harmony Music Release Manager ---${NC}"
DEFAULT_TAG=""
if [[ -f "pubspec.yaml" ]]; then
    DEFAULT_TAG="v$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2 | cut -d'+' -f1)"
fi

if [[ -z "$RELEASE_TAG" ]]; then
    read -p "Do you want to trigger a GitHub Release (build APKs/Linux/Windows)? (y/n): " trigger_release
else
    trigger_release="y"
fi

if [[ "${trigger_release,,}" == "y" ]]; then
    echo -e "${RED}WAIT! Have you updated pubspec.yaml, CHANGELOG.md, release-notes.md, and the in-app version string?${NC}"
    read -p "Proceed with release? (y/n): " confirm_docs
    if [[ "${confirm_docs,,}" != "y" ]]; then
        echo -e "${BLUE}Release aborted. Please update documentation and version strings first.${NC}"
        exit 0
    fi

    if [[ -z "$RELEASE_TAG" ]]; then
        read -p "Enter version tag [${DEFAULT_TAG:-v1.13.4}]: " user_tag
        RELEASE_TAG=${user_tag:-${DEFAULT_TAG:-v1.13.4}}
    fi
    
    if git rev-parse -q --verify "refs/tags/$RELEASE_TAG" >/dev/null; then
        echo -e "${RED}Warning: Tag '$RELEASE_TAG' already exists!${NC}"
        read -p "Replace it? (y/n): " replace_tag
        if [[ "${replace_tag,,}" == "y" ]]; then
            git tag -d "$RELEASE_TAG" 2>/dev/null || true
            git push origin --delete "$RELEASE_TAG" 2>/dev/null || true
        else
            echo -e "${BLUE}Release aborted.${NC}"; exit 0
        fi
    fi
    git tag "$RELEASE_TAG"
    git push origin "$RELEASE_TAG"
    echo -e "${GREEN}Release tag $RELEASE_TAG pushed! GitHub Actions release workflow started.${NC}"
fi
