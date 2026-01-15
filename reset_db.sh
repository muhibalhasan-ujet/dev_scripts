echo 'drop database ujet_development;' | mysql >/dev/null
echo 'drop database ujet_test;' | mysql >/dev/null
echo 'drop database development_kustomermuhibalhasan;' | mysql >/dev/null
echo 'drop database development_sfcomuhibalhasan;' | mysql >/dev/null
echo 'drop database development_zdcomuhibalhasan;' | mysql >/dev/null

rbenv global 3.1.5
bundle config build.debase --global "--with-cflags=-Wno-error=incompatible-function-pointer-types"

cd ~/ujet-server/web
bundle install

echo "Running: bundle exec rake db:create"
bundle exec rake db:create

echo "Running: ALTER DATABASE..."
echo 'ALTER DATABASE ujet_development CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
ALTER DATABASE ujet_test CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;' | mysql >/dev/null

echo "Running: clean dump"
~/ujet-server/ujet-remote.sh clean_dump

echo "Running: bundle exec rake db:schema:load"
bundle exec rake db:schema:load

echo "Running: bundle exec rake db:migrate:with_data"
bundle exec rake db:migrate:with_data

echo "Running: bundle exec rake remotedev:setup"
bundle exec rake remotedev:setup

echo "Running: bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs"
bundle exec rake rp:update_permissions firebase:update_rule redis_cache:clear reset:comms reset:agents reset:jobs