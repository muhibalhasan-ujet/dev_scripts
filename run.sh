#!/bin/bash

# Dockerized version - start UJET services
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

cd "$DEV_PORTAL_ROOT"

echo "Flushing Redis..."
docker compose exec redis redis-cli flushall 2>/dev/null || echo "Redis not running, will flush on start"

case "$1" in
    "be")
        echo "Starting backend services (Rails API + Sidekiq)..."
        docker compose up -d rails-api sidekiq mysql redis rabbitmq

        echo ""
        echo "✅ Backend services started!"
        echo "  - Rails API: http://localhost:5000"
        echo "  - MySQL: localhost:7111"
        echo "  - Redis: localhost:7121"
        echo "  - RabbitMQ: localhost:7131"
        ;;

    "fe")
        echo "Starting frontend services..."
        docker compose up -d frontend envoy

        echo ""
        echo "✅ Frontend services started!"
        echo "  - Frontend: https://company-subdomain.localtest.me:5443"
        ;;

    "all"|*)
        echo "Starting all UJET services..."
        docker compose up -d

        echo ""
        echo "✅ All services started!"
        echo ""
        echo "🌐 Access URLs:"
        echo "  • Dev Portal:    http://localhost:7200"
        echo "  • Frontend App:  https://company-subdomain.localtest.me:5443"
        echo "  • Rails API:     http://localhost:5000"
        echo ""
        echo "📊 Monitor services:"
        echo "  • Service Status: http://localhost:7200/services/status"
        echo "  • Logs (SigNoz):  http://localhost:8080"
        ;;
esac

echo ""
echo "Use 'docker compose logs -f <service>' to view logs"
echo "Use 'docker compose ps' to check service status"
