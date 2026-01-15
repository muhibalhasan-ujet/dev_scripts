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

echo -e "\n\n===UJET CLIENT-----===============================================********************\n\n"
cd ~/ujet-client

git fetch --prune
git reset --hard
git clean -fd
git checkout "$fe_branch_name"
git reset --hard origin/$fe_branch_name

rm -rf node_modules
nvm use

# Logic: if --npm or --pnpm param exists, use that. Otherwise, use pnpm unless release branch < 3.38
install_tool=""
for arg in "$@"; do
    if [[ "$arg" == "--npm" ]]; then
        install_tool="npm"
        break
    elif [[ "$arg" == "--pnpm" ]]; then
        install_tool="pnpm"
        break
    fi
done

if [[ "$install_tool" == "npm" ]]; then
    echo "Using npm for installation (forced by param)"
    npm i
elif [[ "$install_tool" == "pnpm" ]]; then
    echo "Using pnpm for installation (forced by param)"
    corepack enable pnpm
    pnpm install
else
    # No param, use branch/version logic
    if [[ "$fe_branch_name" =~ ^release/([0-9]+)\.([0-9]+)$ ]]; then
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        if (( major < 3 )) || (( major == 3 && minor < 38 )); then
            echo "Using npm for installation (release branch < 3.38)"
            npm i
        else
            echo "Using pnpm for installation (release branch >= 3.38)"
            corepack enable pnpm
            pnpm install
            pnpm run generate:import-map:dev
        fi
    else
        echo "Using pnpm for installation (default)"
        corepack enable pnpm
        pnpm install
        pnpm run generate:import-map:dev
    fi
fi

# Update import-map.json
IMPORT_MAP_FILE="~/ujet-client/microfrontends/root-config/dist/import-map.json"
if [ -f "$IMPORT_MAP_FILE" ]; then
    echo "Updating import-map.json..."
    sed -i 's|"/UJET-root-config.js"|"https://zdcomuhibalhasan.ujetremote.dev/UJET-root-config.js"|g' "$IMPORT_MAP_FILE"
    echo "Updated @UJET/root-config URL in import-map.json"
fi

echo -e "\n\n===UJET SERVER-----===============================================********************\n\n"
cd ~/ujet-server
git fetch --prune
git reset --hard
git clean -fd
git checkout "$be_branch_name"
git reset --hard origin/$be_branch_name

cd web
bundle
bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs
bundle exec rake db:migrate_all


echo -e "\n\n===CHATBOT SERVER-----===============================================********************\n\n"
cd ~/ujet-server/web/chatbot-server
rm -rf node_modules
nvm use
npm i

echo -e "\n\n===CRM ADAPTOR-----===============================================********************\n\n"
cd ~/ujet-server/web/crm_adaptor
rm -rf node_modules
nvm use
npm i

echo -e "\n\n===CRM SERVER-----===============================================********************\n\n"
cd ~/ujet-server/web/crm-server
rm -rf node_modules
nvm use
npm i

echo -e "\n\n===CRM FUNCS-----===============================================********************\n\n"
cd ~/ujet-server/web/crm-funcs
rm -rf node_modules
nvm use
npm i

echo -e "\n\n===NODE MEDIA SERVICE-----===============================================********************\n\n"
cd ~/ujet-node-media-service
git fetch --prune
git reset --hard origin/main
git checkout main
git pull
git reset --hard origin/main
rm -rf node_modules
nvm use
npm i