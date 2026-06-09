#!/bin/bash

# A script to sync your fork with the upstream repository.

# Set the upstream repository URL if not already set
UPSTREAM_URL="https://github.com/anandnet/Harmony-Music.git"

# Check if upstream remote exists, if not, add it
if ! git remote get-url upstream > /dev/null 2>&1; then
    echo "Setting up upstream remote..."
    git remote add upstream "$UPSTREAM_URL"
fi

echo "Fetching upstream changes..."
git fetch upstream

echo "Checking out main branch..."
# Using main or master depending on what the default branch is
BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
if [ -z "$BRANCH" ]; then
    BRANCH="main"
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$BRANCH" ]; then
    echo "Switching to default branch ($BRANCH)..."
    git checkout $BRANCH
fi

echo "Merging upstream/$BRANCH into local $BRANCH..."
git merge upstream/$BRANCH

echo "Pushing changes to origin..."
git push origin $BRANCH

echo "Sync complete!"
