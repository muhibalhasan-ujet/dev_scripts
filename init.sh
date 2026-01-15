#!/bin/bash

# Dockerized version - initialize development environment
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

echo "Initializing UJET development environment..."
echo ""

# Pull latest changes for ujet-client
echo "===PULLING UJET CLIENT====================================="
cd "$PROJECT_ROOT/ujet-client"
git pull

echo ""
echo "===REMOVING NODE_MODULES VOLUMES=========================="
# Remove node_modules volumes to force fresh install
cd "$DEV_PORTAL_ROOT"
docker volume rm ujet-dev_crm_adapter_node_modules 2>/dev/null || true
docker volume rm ujet-dev_crm_server_node_modules 2>/dev/null || true
docker volume rm ujet-dev_chatbot_server_node_modules 2>/dev/null || true
docker volume rm ujet-dev_frontend_node_modules 2>/dev/null || true

echo ""
echo "===REBUILDING CONTAINERS==================================="
# Rebuild and restart containers to reinstall dependencies
docker compose up -d --build crm-adapter crm-server chatbot-server frontend

echo ""
echo "===WAITING FOR SERVICES TO BE READY======================="
sleep 10

echo ""
echo "===RUNNING DATABASE MIGRATIONS============================="
# Run database migrations
docker compose exec rails-api bundle exec rake db:migrate_all

echo ""
echo "✅ Initialization completed successfully!"
echo ""
echo "All services have been restarted with fresh dependencies."
echo "Database migrations have been applied."