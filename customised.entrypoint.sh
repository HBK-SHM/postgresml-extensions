#!/bin/bash
echo "Starting PostgresML"
apt install -y netcat
service postgresql start
echo "Waiting postgres to start"

while ! nc -z localhost 5432; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "postgres launched"

useradd postgresml -m 2> /dev/null 1>&2
sudo -u postgresml touch /home/postgresml/.psql_history
sudo -u postgres createuser root --superuser --login 2> /dev/null 1>&2
sudo -u postgres psql -c "CREATE ROLE postgresml PASSWORD 'postgresml' SUPERUSER LOGIN" 2> /dev/null 1>&2
sudo -u postgres createdb postgresml --owner postgresml 2> /dev/null 1>&2
sudo -u postgres psql -c 'ALTER ROLE postgresml SET search_path TO public,pgml' 2> /dev/null 1>&2

echo "Starting dashboard"
PGPASSWORD=postgresml psql -c 'CREATE EXTENSION IF NOT EXISTS vector' \
	-d postgresml \
	-U postgresml \
	-h 127.0.0.1 \
	-p 5432 2> /dev/null 1>&2

PGPASSWORD=postgresml psql -c 'CREATE EXTENSION IF NOT EXISTS pgml' \
	-d postgresml \
	-U postgresml \
	-h 127.0.0.1 \
	-p 5432 2> /dev/null 1>&2

#!/bin/bash
set -e
export DATABASE_URL=postgres://postgresml:postgresml@127.0.0.1:5432/postgresml
export DASHBOARD_STATIC_DIRECTORY=/usr/share/pgml-dashboard/dashboard-static
export DASHBOARD_CMS_DIRECTORY=/usr/share/pgml-cms
export SEARCH_INDEX_DIRECTORY=/var/lib/pgml-dashboard/search-index
export ROCKET_SECRET_KEY=$(openssl rand -hex 32)
export ROCKET_ADDRESS=0.0.0.0
export RUST_LOG=info
exec /usr/bin/pgml-dashboard > /dev/null 2>&1
trap : TERM INT; sleep infinity & wait