#!/bin/bash
cd ~/ujet-server/web || exit

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
rescue => e
  puts "⚠️  Setup failed: #{e.class} - #{e.message}"
end
# --- End auto setup ---
RUBY

# Launch Rails console with our custom .pryrc
PRYRC="$TMP_RC" bundle exec rails console

# Cleanup temp file
rm -f "$TMP_RC"
