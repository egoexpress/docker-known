docker-known
============

![Anchore Container Scan](https://github.com/egoexpress/docker-known/workflows/Anchore%20Container%20Scan/badge.svg)

Initially based on [Davesgonechina's](https://github.com/davesgonechina) [Docker Known container setup](https://github.com/davesgonechina/docker-known), which itself is based on [Eric Hansander's](https://github.com/ehdr) [Docker Known container](https://registry.hub.docker.com/u/ehdr/known/), this Known Docker configuration is now a complete rewrite on the docker-compose side.

This repo builds a set of containers to run the latest version of [Known](https://withknown.com/) from the 'main' Github branch with one process per container (one for the MariaDB database and one running Apache and the Known PHP application itself).

Changes within the fork
-----------------------
This fork contains the following changes in comparison to [Davesgonechina's original](https://github.com/davesgonechina/docker-known):

- contains an other set of Known plugins (e.g contains Foursquare, but no LinkedIn)
- uses a [nginx reverse proxy](https://github.com/jwilder/nginx-proxy) with TLS through [Let's Encrypt](https://letsencrypt.org)
- uses the latest Ubuntu base image (currently 20.04 LTS 'Focal Fossa')

How to run it
-------------
Just run the docker-compose.yml file in detached mode with [Docker Compose](https://docs.docker.com/compose/) and set the required environment variables.
Don't set `DOCKER_KNOWN_HOSTNAME` and `DOCKER_LETSENCRYPT_EMAIL` if you don't use the nginx reverse proxy.

    export DOCKER_KNOWN_MYSQL_PASSWORD=YOURPASSWORD
    export DOCKER_KNOWN_HOSTNAME=YOURHOSTNAME
    export DOCKER_LETSENCRYPT_EMAIL=YOUREMAIL
    docker-compose -p known up -d

Enter the Known site address into your browser, and follow the instructions to create an account.

If you are running docker locally on your machine, you should be able to
access the Known web interface it at `http://localhost/`.

How to build it
---------------
To build the Docker image locally, simply

    docker build -t egoexpress/known .
