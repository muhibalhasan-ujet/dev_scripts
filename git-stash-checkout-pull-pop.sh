# !/bin/bash

# take a branch name as arg, then stash, checkout, pull, pop

if [ -z "$1" ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

git fetch
git stash
git checkout $1
git pull
git stash pop