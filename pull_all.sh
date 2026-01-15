#!/bin/bash
. ~/.nvm/nvm.sh

redis-cli flushall

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
cd ~/ujet-client

git fetch --prune
git reset --hard origin/$fe_branch_name
git checkout "$fe_branch_name"
git pull
git reset --hard origin/$fe_branch_name

nvm use
corepack enable pnpm
pnpm install

echo "-----UJET SERVER-----"
cd ~/ujet-server
git stash
git fetch --prune
git reset --hard origin/$be_branch_name
git checkout "$be_branch_name"
git pull
git reset --hard origin/$be_branch_name

cd web
bundle
bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs
bundle exec rake db:migrate_all

cd ~/ujet-server/web/chatbot-server
nvm use
npm i

cd ~/ujet-server/web/crm-adaptor
nvm use
npm i

cd ~/ujet-server/web/crm-server
nvm use
npm i

cd ~/ujet-server/web/crm-funcs
nvm use
npm i
