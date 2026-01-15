#!/bin/bash

# Dockerized version - checkout branch, pull, and update dependencies
# This script works with the new Docker Compose development environment

# Check if branch name is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <branch_name>"
  exit 1
fi

branch_name=$1

# Get the current directory name
current_dir=$(pwd)

# Determine the project root (assuming scripts are in ~/ujet/dev_scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

# Check out the specified branch and pull the latest changes
git checkout "$branch_name" && git pull

# Run specific commands based on the directory name
if [[ "$current_dir" == *"ujet-server"* ]]; then
  echo "Detected ujet-server. Running server-specific commands..."

  # Flush Redis using docker compose
  cd "$DEV_PORTAL_ROOT"
  docker compose exec redis redis-cli flushall

  # Bundle install and migrate database
  docker compose exec rails-api bundle install
  docker compose exec rails-api bundle exec rake db:migrate_all

  echo "✅ Server dependencies updated and database migrated"

elif [[ "$current_dir" == *"ujet-client"* ]]; then
  echo "Detected ujet-client. Running client-specific commands..."

  # Restart frontend container to pick up dependency changes
  cd "$DEV_PORTAL_ROOT"
  docker compose down frontend
  docker compose up -d frontend

  echo "✅ Frontend container restarted with updated dependencies"

else
  echo "Current directory is neither ujet-server nor ujet-client. No specific commands to run."
fi
