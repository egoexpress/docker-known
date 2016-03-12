#!/bin/bash
#
# First do all the setup that we could not do in the Dockerfile, since this
# requires input from the docker run command, e.g.:
# - we have remounted volumes due to --volumes-from

set -e

me=`basename -- "$0"`

if [ -z "$KNOWN_MYSQL_PASSWORD" ]; then
    echo >&2 "$me: error: The following environment variable must be set:"
    echo >&2 "$me:      \$KNOWN_MYSQL_PASSWORD"
    echo >&2 "$me:   Add them using the -e option to docker run"
    exit 1
fi

echo "dbpass = '$KNOWN_MYSQL_PASSWORD'" >> /var/www/known/config.ini

# Fix permissions for the uploads directory, since it was mounted by
# --volumes-from when the container was run.
chown -R root:www-data /known/uploads
chmod -R 775 /known/uploads

# The MySQL server is slow to start the very first time you run the mysql
# container, so we have to wait.
# Borrowed from tutum-docker-mysql on GitHub!
LOOP_LIMIT=12
for (( i=0 ; ; i++ )); do
    mysql -h mysql -u known -p$KNOWN_MYSQL_PASSWORD -e "status" > \
        /dev/null 2>&1 \
        && break
    if [ ${i} -eq ${LOOP_LIMIT} ]; then
        echo >&2 "$me: error: Timed out waiting for MySQL service to start"
        echo >&2 "$me:   Double check that you specified the correct MySQL"
        echo >&2 "$me:   user name and password, and that you --link'ed"
        echo >&2 "$me:   the MySQL container using alias: mysql"
        exit 2
    fi
    echo "$me: Waiting for MySQL service to start... ($((i*5))/$((LOOP_LIMIT*5)) seconds)"
    sleep 5
done
echo "$me: Successfully connected to MySQL service"

# We could not init the DB in the Dockerfile, since then we were not yet
# --link'ed to the MySQL container, so do it now. This is idempotent, so it's
# ok to do it every time we run a container even though the DB is in a volume.
mysql -h mysql -u known -p$KNOWN_MYSQL_PASSWORD known \
    < /var/www/known/schemas/mysql/mysql.sql

source /etc/apache2/envvars
exec "$@"
