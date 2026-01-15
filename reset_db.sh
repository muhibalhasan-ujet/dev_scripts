#!/bin/bash

# Dockerized version - reset database
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

cd "$DEV_PORTAL_ROOT"

echo "⚠️  WARNING: This will drop all databases and reset to a clean state!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

echo ""
echo "Dropping databases..."
docker compose exec mysql mysql -e 'DROP DATABASE IF EXISTS ujet_development;' 2>/dev/null || true
docker compose exec mysql mysql -e 'DROP DATABASE IF EXISTS ujet_test;' 2>/dev/null || true
docker compose exec mysql mysql -e 'DROP DATABASE IF EXISTS development_kustomermuhibalhasan;' 2>/dev/null || true
docker compose exec mysql mysql -e 'DROP DATABASE IF EXISTS development_sfcomuhibalhasan;' 2>/dev/null || true
docker compose exec mysql mysql -e 'DROP DATABASE IF EXISTS development_zdcomuhibalhasan;' 2>/dev/null || true

echo ""
echo "Running: bundle exec rake db:create"
docker compose exec rails-api bundle exec rake db:create

echo ""
echo "Running: ALTER DATABASE..."
docker compose exec mysql mysql -e 'ALTER DATABASE ujet_development CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;' 2>/dev/null || true
docker compose exec mysql mysql -e 'ALTER DATABASE ujet_test CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;' 2>/dev/null || true

echo ""
echo "Running: bundle exec rake db:schema:load"
docker compose exec rails-api bundle exec rake db:schema:load

echo ""
echo "Running: bundle exec rake db:migrate:with_data"
docker compose exec rails-api bundle exec rake db:migrate:with_data

echo ""
echo "Running: bundle exec rake remotedev:setup"
docker compose exec rails-api bundle exec rake remotedev:setup

echo ""
echo "Running: bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs"
docker compose exec rails-api bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs

echo ""
echo "✅ Database reset completed successfully!"
echo ""
echo "Note: If you need to run clean_dump, please do it manually:"
echo "  cd $PROJECT_ROOT/ujet-server && ./ujet-remote.sh clean_dump"