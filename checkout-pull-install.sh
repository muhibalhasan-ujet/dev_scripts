#!/bin/bash

# Check if branch name is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <branch_name>"
  exit 1
fi

branch_name=$1

# Check out the specified branch and pull the latest changes
git checkout "$branch_name" && git pull

# Get the current directory name
current_dir=$(pwd)

# Run specific commands based on the directory name
if [[ "$current_dir" == *"ujet-server"* ]]; then
  echo "Detected ujet-server. Running server-specific commands..."
  cd ~/ujet-server/web
  redis-cli flushall
  bundle install
  bundle exec rake db:migrate_all
elif [[ "$current_dir" == *"ujet-client"* ]]; then
  echo "Detected ujet-client. Running client-specific commands..."
  cd ~/ujet-client && nvm use && npm install
else
  echo "Current directory is neither ujet-server nor ujet-client. No specific commands to run."
fi
