docker-known
============

A quick and dirty copy of [Eric Hansander's][1] Docker Known container with untested dockerfile updated from v0.6.5 to v0.7.8.5.

Run the [Known][2] social publishing platform in a [Docker][3] container!

This unofficial image uses the 0.7.8.5 ("Makeba") release of Known, and has been
designed to run one process per container, i.e.:

- one container used as [data volume][4] for settings, posts, etc.
- MySQL database running in one container (based on the [standard MySQL image][5])
- Apache running the Known PHP application in a container based on this image

**Note:** This Docker image has known (and most likely also unknown) problems
(see the [known issues][8]). If you want to deploy Known publicly, you should have
a look at the [official installation instructions][9]. And of course, please help
[report issues][8] as you find them!

How to run it
-------------
You can run it [the easy way](#how-to-run-it-using-docker-compose-formerly-known-as-fig) or the hard(er) way.
Let's start with the hard(er) way.

### First, create a data volume container
The data volume container will contain the MySQL database files and the Known
uploads directory (for uploaded photos, etc.):

    docker run --name datavolume \
        -v /var/lib/mysql \
        -v /known/uploads \
        -d ubuntu:trusty true

### Second, start the MySQL database server
Here you need to decide on passwords for the MySQL root user and for the MySQL
user account for the Known app:

    docker run --name mysql --volumes-from datavolume \
        -e MYSQL_DATABASE=known \
        -e MYSQL_USER=known \
        -e MYSQL_PASSWORD=knownpassword \
        -e MYSQL_ROOT_PASSWORD=rootpassword \
        -d mysql

### Third, start the actual Known app
Again, you need to pass in the MySQL information you decided on in the
previous step:

    docker run --name known --volumes-from datavolume --link mysql:mysql -p 80:80 \
        -e MYSQL_DATABASE=known \
        -e MYSQL_USER=known \
        -e MYSQL_PASSWORD=knownpassword \
        -d ehdr/known

Notes:

- the `--link` alias for the MySQL container (the part after the '`:`') must be
  exactly `mysql`
- the current version of Known (0.6.5) only supports running on port 80

How to run it using Docker Compose (Formerly known as Fig)
----------------------------------------------------------
[Docker Compose][7] offers a convenient way to start all the containers automatically.
Once you have Compose installed, just put something like the following in
a `docker-compose.yml` file and run `docker-compose up -d` (but promise to pick good passwords
first!):

    datavolume:
      image: ubuntu:trusty
      volumes:
        - /var/lib/mysql
        - /known/uploads
    
    mysql:
      image: mysql
      volumes_from:
        - datavolume
      environment:
        - MYSQL_DATABASE=known
        - MYSQL_USER=known
        - MYSQL_PASSWORD=knownpassword
        - MYSQL_ROOT_PASSWORD=rootpassword
    
    known:
      image: ehdr/known
      volumes_from:
        - datavolume
      environment:
        - MYSQL_DATABASE=known
        - MYSQL_USER=known
        - MYSQL_PASSWORD=knownpassword
      ports:
        - "80:80"
      links:
        - "mysql:mysql"

Finally, set up Known!
----------------------
Enter the Known site address into your browser, and follow the instructions.

If you are running docker locally on your machine, you should be able to
access it at `http://localhost/`.  If you are running [boot2docker][6], you
instead need to enter the local IP of your boot2docker virtual machine, which
you can find by running

    boot2docker ip

How to build it
---------------
To build the image locally, simply

    docker build -t ehdr/known .

[1]: https://github.com/ehdr
[2]: https://withknown.com/
[3]: https://www.docker.com/
[4]: http://docs.docker.com/userguide/dockervolumes/
[5]: https://github.com/docker-library/mysql
[6]: http://boot2docker.io/
[7]: https://docs.docker.com/compose/
[8]: https://github.com/ehdr/docker-known/issues
[9]: http://docs.withknown.com/en/latest/install/index.html
