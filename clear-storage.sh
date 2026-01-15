#!/bin/bash

# Absolute paths to the log files
DEVELOPMENT_LOG="/home/muhibalhasan/ujet-server/web/log/development.log"
TEST_LOG="/home/muhibalhasan/ujet-server/web/log/test.log"
CLEAN_DUMP_LOG="/home/muhibalhasan/ujet-server/web/log/clean_dump.log"

# Absolute paths to additional log files in /var/log/ujet
CRM_ADAPTOR_LOG="/var/log/ujet/crm-adaptor.log"
CRM_SERVER_LOG="/var/log/ujet/crm-server.log"
FRONTEND_LOG="/var/log/ujet/frontend.log"
RAILS_LOG="/var/log/ujet/rails.log"
SIDEKIQ_LOG="/var/log/ujet/sidekiq.log"
UJET_NODE_MEDIA_SERVICE_LOG="/var/log/ujet/ujet-node-media-service.log"

# Display storage information before clearing logs and profiles
echo "Storage information before cleanup:"
df -h /

# Clear the contents of the log files
> "$DEVELOPMENT_LOG"
> "$TEST_LOG"
> "$CLEAN_DUMP_LOG"
> "$CRM_ADAPTOR_LOG"
> "$CRM_SERVER_LOG"
> "$FRONTEND_LOG"
> "$RAILS_LOG"
> "$SIDEKIQ_LOG"
> "$UJET_NODE_MEDIA_SERVICE_LOG"

echo "The contents of the log files have been cleared."

# Navigate to the tmp directory
cd /tmp

# Delete puppeteer profiles
find . -maxdepth 1 -name 'puppeteer_dev_chrome_profile-*' -delete

# Remove journal log files older than 1 weeks
sudo journalctl --vacuum-time=1weeks

# Display storage information after cleanup
echo "Storage information after cleanup:"
df -h /