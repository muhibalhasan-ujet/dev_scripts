#!/bin/bash
. ~/.nvm/nvm.sh

ports=(3000 5000 7433 3435 5045 6060 4050 5050 5080 5081 7777 8888)
for port in "${ports[@]}"; do
    pid=$(lsof -t -i :$port)
    if [ -n "$pid" ]; then
        echo "Port $port is in use by PID $pid. Killing process..."
        kill -9 $pid
        echo "Process with PID $pid killed."
    else
        echo "Port $port is not in use."
    fi
done

redis-cli flushall


case "$1" in
    "be")
        echo "Running backend"
        cd ~/ujet-server
        ./ujet-remote.sh run rails
        ;;
    "fe")
        echo "Running frontend"
        cd ~/ujet-server
        ./ujet-remote.sh run fe
        ;;
    *)
        cd ~/ujet-node-theme-service
        nvm use
        npm run start > /var/log/ujet/theme.log&
        cd ~/ujet-server
        ./ujet-remote.sh run
        ;;
esac

# Update import-map.json
IMPORT_MAP_FILE="~/ujet-client/microfrontends/root-config/dist/import-map.json"
if [ -f "$IMPORT_MAP_FILE" ]; then
    echo "Updating import-map.json..."
    sed -i 's|"/UJET-root-config.js"|"https://zdcomuhibalhasan.ujetremote.dev/UJET-root-config.js"|g' "$IMPORT_MAP_FILE"
    echo "Updated @UJET/root-config URL in import-map.json"
fi

# if [ -z $1 ]; then
    
# else
    # cd ~/ujet-node-theme-service
    # nvm use
    # npm run start > /var/log/ujet/theme.log&
    # cd ~/ujet-server
    # ./ujet-remote.sh run
# fi
