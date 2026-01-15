. ~/.nvm/nvm.sh

cd ~/ujet-server/web/crm_adaptor
rm -rf node_modules
nvm use
npm i

cd ~/ujet-server/web/crm-server
rm -rf node_modules
nvm use
npm i

cd ~/ujet-server/web/chatbot-server
rm -rf package-lock.json node_modules
nvm use
npm i

cd ~/ujet-client
git pull
rm -rf node_modules
nvm use
npm i

cd ~/ujet-server/web
bundle exec rake db:migrate_all