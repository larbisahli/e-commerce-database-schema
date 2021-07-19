#!/bin/bash
set -e

# <-- Create Development Database -->

# \i <filename>  --to run (include) a script file of SQL commands.
# \c <database>  --to connect to a different database
# Copy init.sql file to a docker volume in /var/lib/data/init.sql to gain access to init.sql inside the container.

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $POSTGRES_DEV_USER WITH PASSWORD '$POSTGRES_DEV_PASSWORD';
    CREATE DATABASE $POSTGRES_DEV_DB;
    GRANT CONNECT ON DATABASE $POSTGRES_DEV_DB TO $POSTGRES_DEV_USER;
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DEV_DB TO $POSTGRES_DEV_USER;
    \c $POSTGRES_DEV_DB;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_DEV_USER;
    ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO $POSTGRES_DEV_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO $POSTGRES_DEV_USER;
    \i /var/lib/data/init.sql;
EOSQL