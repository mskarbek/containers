#!/usr/bin/env bash
export PGDATA="/var/lib/pgsql/18/data"

if [ -z "$( ls -A ${PGDATA} )" ]; then
    if [ -z "${PG_POSTGRES_PASSWORD}" ]; then
        cat /proc/sys/kernel/random/uuid > /tmp/pwfile
        printf "PastgreSQL postgres user password: "
        cat /tmp/pwfile
    else
        echo ${PG_POSTGRES_PASSWORD} > /tmp/pwfile
    fi

    /usr/pgsql-18/bin/initdb --auth-host=scram-sha-256 --pwfile=/tmp/pwfile --locale=C.UTF-8 --encoding=UTF8
    sed -Ei 's/(#listen_addresses = .*)/listen_addresses = '\''*'\''\n\1/' ${PGDATA}/postgresql.conf
    echo "host    all             all             0.0.0.0/0               scram-sha-256" >> ${PGDATA}/pg_hba.conf
fi

sudo /usr/bin/chmod 0700 /var/lib/pgsql/18/data
sudo /usr/bin/chown -R postgres:postgres /var/lib/pgsql/18/data

/usr/pgsql-18/bin/postgresql-18-check-db-dir ${PGDATA}

exec /usr/pgsql-18/bin/postgres -D ${PGDATA}
