[![Code Climate](https://codeclimate.com/github/egoexpress/innoxmpp/badges/gpa.svg)](https://codeclimate.com/github/egoexpress/innoxmpp)

docker-known
============

Based on [Davesgonechina's](https://github.com/davesgonechina) [Docker Known container setup](https://github.com/davesgonechina/docker-known), which in itself is based on [Eric Hansander's](https://github.com/ehdr) [Docker Known container](https://registry.hub.docker.com/u/ehdr/known/).

This builds a set of containers to run the latest version of [Known](https://withknown.com/) with one process per container (one container for the [data volume](http://docs.docker.com/userguide/dockervolumes/), one for the database and one running Apache and the Known PHP application itself).

Changes within the fork
-----------------------
This fork contains the following changes in comparison to [Davesgonechina's original](https://github.com/davesgonechina/docker-known):

- contains an other set of Known plugins (e.g contains Foursquare, but no LinkedIn)
- runs on a Debian base image instead of Ubuntu (this is out of personal preference).
- uses a [nginx reverse proxy](https://github.com/jwilder/nginx-proxy) with TLS through [Let's Encrypt](https://letsencrypt.org)

This image used to use MongoDB instead of MySQL, but as the Known developers seem to favor MySQL and some strange errors using MongoDB occured the project switched back to use MySQL (using the official MySQL docker image).

How to run it
-------------
Just run the docker-compose.yml file in detached mode with [Docker Compose](https://docs.docker.com/compose/):

    export KNOWN_MYSQL_PASSWORD=YORPASSWORD
    export DOCKER_KNOWN_HOSTNAME=YOURHOSTNAME
    export DOCKER_LETSENCRYPT_EMAIL=YOUREMAIL
    docker-compose up -d

Or alternatively, run the following from the command line:

The data volume container will contain the MySQL database files and the Known uploads directory (for uploaded photos, etc.). Mounting a host directory allows you to rebuild the containers without losing your content or settings.

    docker run --name datavolume \
        -v your local directory here:/var/lib/mysql \
        -v your local directory here:/known/uploads \
        -d debian:testing true


    docker run --name mysql --volumes-from datavolume \
        -d mysql


    docker run --name known --volumes-from datavolume --link mysql:mysql -p 80:80 \
        -d egoexpress/known

Enter the Known site address into your browser, and follow the instructions to create an account.

If you are running docker locally on your machine, you should be able to
access it at `http://localhost/`.  If you are running [boot2docker](http://boot2docker.io/), you
instead need to enter the local IP of your boot2docker virtual machine, which
you can find by running

    boot2docker ip

How to build it
---------------
To build the image locally, simply

    docker build -t egoexpress/known .
