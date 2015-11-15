#!/bin/bash
#
# First do all the setup that we could not do in the Dockerfile, since this
# requires input from the docker run command, e.g.:
# - we have remounted volumes due to --volumes-from

set -e

me=`basename -- "$0"`

# Fix permissions for the uploads directory, since it was mounted by
# --volumes-from when the container was run.
chown -R root:www-data /known/uploads
chmod -R 775 /known/uploads

source /etc/apache2/envvars
exec "$@"
