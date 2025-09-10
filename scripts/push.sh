#!/bin/bash
set -e

# Find all submodules from .gitmodules
SUBMODULES=$(git config -f .gitmodules --get-regexp path | awk '{ print $2 }')

echo "📦 Available submodules:"
select SUBMODULE_PATH in $SUBMODULES; do
  if [ -n "$SUBMODULE_PATH" ]; then
    echo "➡️ You selected: $SUBMODULE_PATH"
    break
  else
    echo "❌ Invalid choice. Try again."
  fi
done

# Ask for commit message
read -p "📝 Enter commit message for $SUBMODULE_PATH: " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"update submodule"}

# Step 1: Commit & push inside submodule
echo "➡️ Working in submodule: $SUBMODULE_PATH"
cd $SUBMODULE_PATH

git checkout main
git add .
git commit -m "$COMMIT_MSG" || echo "⚠️ Nothing to commit in $SUBMODULE_PATH"
git push origin main || echo "⚠️ Could not push $SUBMODULE_PATH"

# Step 2: Update parent repo pointer
echo "➡️ Updating parent repo pointer..."
cd - > /dev/null  # go back to root repo
git add $SUBMODULE_PATH
git commit -m "chore: bump $SUBMODULE_PATH to latest main"
git push origin main

echo "✅ Submodule $SUBMODULE_PATH pushed & parent updated."
