#!/bin/bash

# Dockerized version - clear Docker container logs and cleanup storage
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

# Display storage information before cleanup
echo "Storage information before cleanup:"
df -h /
echo ""
echo "Docker disk usage before cleanup:"
docker system df

echo ""
echo "Clearing Docker container logs..."

# Get list of all UJET containers
cd "$DEV_PORTAL_ROOT"
CONTAINERS=$(docker compose ps -q 2>/dev/null)

if [ -n "$CONTAINERS" ]; then
    # Truncate logs for each container
    for container in $CONTAINERS; do
        container_name=$(docker inspect --format='{{.Name}}' "$container" | sed 's/^\///')
        log_file=$(docker inspect --format='{{.LogPath}}' "$container")

        if [ -f "$log_file" ]; then
            echo "Clearing logs for: $container_name"
            sudo truncate -s 0 "$log_file" 2>/dev/null || echo "  (skipped - no permission)"
        fi
    done
else
    echo "No running containers found."
fi

echo ""
echo "Clearing local Rails log files (if mounted)..."
# Clear Rails logs in the mounted volume
if [ -d "$PROJECT_ROOT/ujet-server/web/log" ]; then
    > "$PROJECT_ROOT/ujet-server/web/log/development.log" 2>/dev/null || true
    > "$PROJECT_ROOT/ujet-server/web/log/test.log" 2>/dev/null || true
    > "$PROJECT_ROOT/ujet-server/web/log/clean_dump.log" 2>/dev/null || true
    echo "Rails log files cleared."
fi

echo ""
echo "Cleaning up Docker system..."
# Remove unused Docker resources
docker system prune -f

echo ""
echo "Removing old Docker images..."
# Remove dangling images
docker image prune -f

echo ""
echo "Cleaning up temporary files..."
# Navigate to the tmp directory
cd /tmp

# Delete puppeteer profiles
find . -maxdepth 1 -name 'puppeteer_dev_chrome_profile-*' -delete 2>/dev/null || true

# Remove journal log files older than 1 week (if available)
if command -v journalctl >/dev/null 2>&1; then
    echo "Cleaning system journal logs..."
    sudo journalctl --vacuum-time=1weeks 2>/dev/null || echo "  (skipped - no permission)"
fi

echo ""
echo "Storage information after cleanup:"
df -h /
echo ""
echo "Docker disk usage after cleanup:"
docker system df

echo ""
echo "✅ Cleanup completed successfully!"