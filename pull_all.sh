#!/bin/bash

# Dockerized version - pull all repositories and restart containers
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

fe_branch_name="master"
be_branch_name="master"

if [ -n "$1" ]; then
    be_branch_name=$1
fi
if [ -n "$2" ]; then
    fe_branch_name=$2
elif [ -n "$1" ]; then
    fe_branch_name=$1
fi

echo "-----UJET CLIENT-----"
cd "$PROJECT_ROOT/ujet-client"

git fetch --prune
git reset --hard origin/$fe_branch_name
git checkout "$fe_branch_name"
git pull
git reset --hard origin/$fe_branch_name

echo "-----UJET SERVER-----"
cd "$PROJECT_ROOT/ujet-server"
git stash
git fetch --prune
git reset --hard origin/$be_branch_name
git checkout "$be_branch_name"
git pull
git reset --hard origin/$be_branch_name

echo ""
echo "-----FLUSHING REDIS-----"
cd "$DEV_PORTAL_ROOT"
docker compose exec redis redis-cli flushall

echo ""
echo "-----RESTARTING CONTAINERS-----"
# Restart containers to pick up code changes
docker compose restart rails-api sidekiq frontend chatbot-server crm-adapter crm-server

echo ""
echo "-----WAITING FOR SERVICES TO BE READY-----"
sleep 10

echo ""
echo "-----RUNNING RAILS SETUP TASKS-----"
docker compose exec rails-api bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs
docker compose exec rails-api bundle exec rake db:migrate_all

echo ""
echo "✅ Pull all completed successfully!"
echo "All repositories updated to:"
echo "  - Frontend: $fe_branch_name"
echo "  - Backend: $be_branch_name"
echo ""
echo "All containers restarted."
