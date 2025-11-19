#!/bin/bash

SUBMODULE_PATH="better-mflowgen"
SUBMODULE_URL="https://github.com/thedubbers9/better-mflowgen-repo.git"

UPDATE_ONLY=false

ORIG_DIR=$(pwd)

# Parse command-line options
while getopts "u" opt; do
  case $opt in
    u)
      UPDATE_ONLY=true
      ;;
    *)
      echo "Usage: $0 [-u]"
      echo "  -u   Update submodule to latest origin commit"
      exit 1
      ;;
  esac
done

# Determine which branch the submodule tracks (handles detached HEAD)
get_submodule_branch() {
  cd "$SUBMODULE_PATH" || return 1
  BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$BRANCH" ]; then
    BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
  fi
  if [ -z "$BRANCH" ]; then
    BRANCH="main"
  fi
  cd - >/dev/null || return 1
  echo "$BRANCH"
}

# Update submodule to latest commit on its branch
update_submodule() {
  if [ -d "$SUBMODULE_PATH" ]; then
    BRANCH=$(get_submodule_branch)
    echo "Updating '$SUBMODULE_PATH' on branch '$BRANCH'..."
    cd "$SUBMODULE_PATH" || return 1

    git fetch origin "$BRANCH"
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" "origin/$BRANCH"
    git pull origin "$BRANCH"

    cd - >/dev/null || return 1
    git add "$SUBMODULE_PATH"
    echo "Submodule updated to latest commit on '$BRANCH'."
  else
    echo "Submodule directory '$SUBMODULE_PATH' not found. Run without -u first."
  fi
}

# Add submodule if missing
if ! git config --file .gitmodules --get-regexp path | grep -q "$SUBMODULE_PATH"; then
  echo "Adding submodule '$SUBMODULE_PATH'..."
  git submodule add "$SUBMODULE_URL" "$SUBMODULE_PATH"
  git submodule update --init --recursive "$SUBMODULE_PATH"
  echo "Submodule added successfully."
else
  echo "Submodule '$SUBMODULE_PATH' already exists."
  git submodule update --init --recursive "$SUBMODULE_PATH"
fi

# Run update logic if -u flag was passed
if [ "$UPDATE_ONLY" = true ]; then
  update_submodule
fi

# Check if mflowgen is available; run setup if missing
if ! command -v mflowgen &> /dev/null; then
  echo "'mflowgen' not found in PATH. Running setup script..."
  cd "$SUBMODULE_PATH" || exit 1
  source run_setup.sh
  cd - >/dev/null || exit 1
else
  echo "'mflowgen' already available on PATH. Skipping setup."
fi

# Define alias for convenience
alias better_mflowgen='python3 $(pwd)/better-mflowgen/automated_run.py'

echo "Setup complete. You can now run 'better_mflowgen' directly."

# Return to original directory
cd "$ORIG_DIR"
