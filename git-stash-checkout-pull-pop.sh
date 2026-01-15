#!/bin/bash

# Dockerized version - stash, checkout, pull, and pop
# This script works with the new Docker Compose development environment
# Note: Git operations remain the same, but we may need to restart containers

if [ -z "$1" ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

# Get current directory to determine which repo we're in
current_dir=$(pwd)

echo "Switching to branch: $1"
git fetch
git stash
git checkout "$1"
git pull
git stash pop

# Determine if we need to restart containers based on the repository
if [[ "$current_dir" == *"ujet-server"* ]]; then
    echo ""
    echo "Detected ujet-server repository."
    read -p "Do you want to restart Rails containers? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$DEV_PORTAL_ROOT"
        docker compose restart rails-api sidekiq
        echo "✅ Rails containers restarted"
    fi

elif [[ "$current_dir" == *"ujet-client"* ]]; then
    echo ""
    echo "Detected ujet-client repository."
    read -p "Do you want to restart Frontend container? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$DEV_PORTAL_ROOT"
        docker compose restart frontend
        echo "✅ Frontend container restarted"
    fi

elif [[ "$current_dir" == *"ujet-node"* ]] || [[ "$current_dir" == *"ujet-agent-desktop"* ]] || [[ "$current_dir" == *"ujet-vue-websdk"* ]]; then
    echo ""
    echo "Detected Node.js service repository."
    echo "You may need to restart the corresponding Docker container manually."
    echo "Use: cd $DEV_PORTAL_ROOT && docker compose restart <service-name>"
fi

echo ""
echo "✅ Branch switch completed successfully!"