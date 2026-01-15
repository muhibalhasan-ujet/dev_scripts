#!/bin/bash

# Dockerized version - clean pull all repos and rebuild containers
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

echo -e "\n\n===UJET CLIENT-----===============================================********************\n\n"
cd "$PROJECT_ROOT/ujet-client"

git fetch --prune
git reset --hard
git clean -fd
git checkout "$fe_branch_name"
git reset --hard origin/$fe_branch_name

echo -e "\n\n===UJET SERVER-----===============================================********************\n\n"
cd "$PROJECT_ROOT/ujet-server"
git fetch --prune
git reset --hard
git clean -fd
git checkout "$be_branch_name"
git reset --hard origin/$be_branch_name

echo -e "\n\n===NODE MEDIA SERVICE-----===============================================********************\n\n"
cd "$PROJECT_ROOT/ujet-node-media-service"
git fetch --prune
git reset --hard origin/main
git checkout main
git pull
git reset --hard origin/main

echo -e "\n\n===STOPPING CONTAINERS-----===============================================********************\n\n"
cd "$DEV_PORTAL_ROOT"
docker compose down

echo -e "\n\n===FLUSHING REDIS-----===============================================********************\n\n"
# Start redis temporarily to flush it
docker compose up -d redis
sleep 2
docker compose exec redis redis-cli flushall
docker compose stop redis

echo -e "\n\n===REMOVING NODE_MODULES VOLUMES-----===============================================********************\n\n"
# Remove node_modules volumes to force fresh install
docker volume rm ujet-dev_frontend_node_modules 2>/dev/null || true
docker volume rm ujet-dev_chatbot_server_node_modules 2>/dev/null || true
docker volume rm ujet-dev_crm_adapter_node_modules 2>/dev/null || true
docker volume rm ujet-dev_crm_server_node_modules 2>/dev/null || true
docker volume rm ujet-dev_crm_funcs_node_modules 2>/dev/null || true
docker volume rm ujet-dev_media_service_node_modules 2>/dev/null || true

echo -e "\n\n===REBUILDING AND STARTING CONTAINERS-----===============================================********************\n\n"
cd "$DEV_PORTAL_ROOT"
docker compose up -d --build

echo -e "\n\n===WAITING FOR RAILS TO BE READY-----===============================================********************\n\n"
sleep 10

echo -e "\n\n===RUNNING RAILS SETUP TASKS-----===============================================********************\n\n"
docker compose exec rails-api bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs
docker compose exec rails-api bundle exec rake db:migrate_all

echo -e "\n\n✅ Clean pull completed successfully!===============================================********************\n\n"
echo "All repositories updated to:"
echo "  - Frontend: $fe_branch_name"
echo "  - Backend: $be_branch_name"
echo "  - Media Service: main"
echo ""
echo "All containers rebuilt and started with fresh dependencies."