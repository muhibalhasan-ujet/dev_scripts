#!/bin/bash

# Dockerized version - start Rails console with tenant helpers
# This script works with the new Docker Compose development environment

# Determine the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_PORTAL_ROOT="$PROJECT_ROOT/ujet-dev-portal"

cd "$DEV_PORTAL_ROOT"

# Create a temporary .pryrc file
TMP_RC=$(mktemp)

cat > "$TMP_RC" <<'RUBY'
# --- Auto setup for Rails console session ---
begin
  # Load companies
  zdco = Company.find_by(subdomain: "zdcomuhibalhasan")
  sfco = Company.find_by(subdomain: "sfcomuhibalhasan")
  kustomer = Company.find_by(subdomain: "kustomermuhibalhasan")

  # Define a module with tenant helper methods
  module TenantHelpers
    def switchz; TenantSelect.switch!("zdcomuhibalhasan"); end
    def switchs; TenantSelect.switch!("sfcomuhibalhasan"); end
    def switchk; TenantSelect.switch!("kustomermuhibalhasan"); end
  end

  # Make methods available in the top-level Pry session
  extend TenantHelpers

  # Switch to default tenant
  switchz

  puts "✅ Tenant switched to zdcomuhibalhasan"
  puts ""
  puts "Available tenant helpers:"
  puts "  switchz - Switch to zdcomuhibalhasan"
  puts "  switchs - Switch to sfcomuhibalhasan"
  puts "  switchk - Switch to kustomermuhibalhasan"
rescue => e
  puts "⚠️  Setup failed: #{e.class} - #{e.message}"
end
# --- End auto setup ---
RUBY

echo "Starting Rails console in Docker container..."
echo ""

# Copy the .pryrc file to a location accessible by the container
TMP_RC_NAME=$(basename "$TMP_RC")
cp "$TMP_RC" "$PROJECT_ROOT/ujet-server/web/.pryrc.tmp"

# Launch Rails console with our custom .pryrc
docker compose exec -e PRYRC=/app/.pryrc.tmp rails-api bundle exec rails console

# Cleanup temp file
rm -f "$TMP_RC"
rm -f "$PROJECT_ROOT/ujet-server/web/.pryrc.tmp"
