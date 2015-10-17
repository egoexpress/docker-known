docker-known
============

Based on [Eric Hansander's](https://github.com/ehdr) [Docker Known container](https://registry.hub.docker.com/u/ehdr/known/), builds a set of containers to run the latest version of [Known](https://withknown.com/) with one process per container, i.e.:

- one container used as [data volume](http://docs.docker.com/userguide/dockervolumes/) for settings, posts, etc.
- MySQL database running in one container (based on the [standard MySQL image](https://github.com/docker-library/mysql))
- Apache running the Known PHP application in a container based on this image

How to run it
-------------
Just run the docker-compose.yml file in detached mode with [Docker Compose](https://docs.docker.com/compose/):

    docker-compose up -d

Or alternatively, run the following from the command line:

The data volume container will contain the MySQL database files and the Known
uploads directory (for uploaded photos, etc.). Mounting a host directory allows you to rebuild the containers without losing your content or settings.

    docker run --name datavolume \
        -v your local directory here:/var/lib/mysql \
        -v your local directory here:/known/uploads \
        -d ubuntu:trusty true


    docker run --name mysql --volumes-from datavolume \
        -e MYSQL_DATABASE=known \
        -e MYSQL_USER=known \
        -e MYSQL_PASSWORD=knownpassword \
        -e MYSQL_ROOT_PASSWORD=rootpassword \
        -d mysql


    docker run --name known --volumes-from datavolume --link mysql:mysql -p 80:80 \
        -e MYSQL_DATABASE=known \
        -e MYSQL_USER=known \
        -e MYSQL_PASSWORD=knownpassword \
        -d davesgonechina/known

Enter the Known site address into your browser, and follow the instructions.

If you are running docker locally on your machine, you should be able to
access it at `http://localhost/`.  If you are running [boot2docker](http://boot2docker.io/), you
instead need to enter the local IP of your boot2docker virtual machine, which
you can find by running

    boot2docker ip

How to build it
---------------
To build the image locally, simply

    docker build -t davesgonechina/known .
