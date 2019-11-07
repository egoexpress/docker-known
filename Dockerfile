# Dockerfile for Known using MySQL/MariaDB
# initially forked from davesgonechina/docker-known
# inspired by ehdr/known and indiepaas/known

FROM ubuntu:disco

LABEL description="Image for Known (withknown.com) using MySQL/MariaDB as backend" \
      version="githead" \
      authors="Bjoern Stierand <bjoern-known@innovention.de>"

ENV branch master
ENV known_url https://codeload.github.com/idno/known/tar.gz/${branch}
ENV DEBIAN_FRONTEND noninteractive

# Install Apache and extensions
# [Known PHP depepndencies](http://docs.withknown.com/en/latest/install/requirements.html),
# as of the 0.8.2 ("Giotto") release:
# - curl
# - date (included in libapache2-mod-php5)
# - dom (included in libapache2-mod-php5)
# - gd
# - json (included in libapache2-mod-php5)
# - libxml (included in libapache2-mod-php5)
# - mbstring (included in libapache2-mod-php5)
# - mysql
# - reflection (included in libapache2-mod-php5)
# - session (included in libapache2-mod-php5)
# - xmlrpc
RUN apt-get update && \
    apt-get -yq --no-install-recommends install gnupg2 && \
    rm -rf /var/lib/apt/lists/*

# add PPA for PHP 7.3
COPY files/php7.3.list /etc/apt/sources.list.d/php7.3.list

# add PGP key for PHP 7.3 PPA, install all required packages
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
    apt-get -yq --no-install-recommends install \
		  apache2 \
		  composer \
		  libapache2-mod-php7.3 \
		  git \
		  php7.3-curl \
		  php7.3-gd \
		  php7.3-mysql \
      php7.3-xmlrpc \
      php7.3-mbstring \
      php7.3-xml \
      mysql-client \
      unzip \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache
RUN cd /etc/apache2/mods-enabled \
	&& ln -s ../mods-available/rewrite.load .

# Download and extract Known distribution
RUN mkdir -p /var/www/known \
  && cd /var/www/known \
  && curl -s ${known_url} | tar -xzf - \
  && mv known-master/* /var/www/known \
  && mv known-master/.htaccess /var/www/known \
  && rm -r known-master

# Configure Apache
COPY apache2/sites-available/known.conf /etc/apache2/sites-available/

# Configure Known
WORKDIR /var/www/known

# This adds a unique file that changes when the branch changes for cache busting
ADD https://api.github.com/repos/idno/known/git/refs/heads/$BRANCH version.json

COPY config.ini .

RUN chmod 644 config.ini \
	&& composer install --prefer-dist \
	&& chown -R www-data:www-data /var/www/known/ \
	&& cd /etc/apache2/sites-enabled \
	&& chmod 644 ../sites-available/known.conf \
	&& rm -f 000-default.conf \
	&& ln -s ../sites-available/known.conf .

RUN composer require egoexpress/known-shortprofile \
      egoexpress/known-smallheader \
      egoexpress/known-pinboard \
      idno/twitter \
      idno/flickr

WORKDIR /var/www/known/IdnoPlugins

# Add Facebook plugin
RUN curl -s https://codeload.github.com/idno/Facebook/tar.gz/master | tar xzf - \
  && mv Facebook-master/ Facebook

# Add SoundCloud plugin
RUN curl -s https://codeload.github.com/idno/SoundCloud/tar.gz/master | tar xzf - \
  && mv SoundCloud-master/ SoundCloud

# Add WordPress plugin
RUN curl -s https://codeload.github.com/idno/WordPress/tar.gz/master | tar xzf - \
  && mv WordPress-master/ WordPress

# Add Diigo plugin
RUN curl -s https://codeload.github.com/idno/Diigo/tar.gz/master | tar xzf - \
  && mv Diigo-master/ Diigo

# Add Foursquare plugin
RUN  curl -s https://codeload.github.com/idno/Foursquare/tar.gz/master | tar xzf - \
  && mv Foursquare-master/ Foursquare

# Add Markdown plugin
RUN  curl -s https://codeload.github.com/idno/Markdown/tar.gz/master | tar xzf - \
  && mv Markdown-master/ Markdown

# Add Pushover plugin
RUN  curl -s https://codeload.github.com/timmmmyboy/Pushover/tar.gz/master | tar xzf - \
  && mv Pushover-master/ Pushover

# Add Reactions plugin
RUN curl -s https://codeload.github.com/kylewm/KnownReactions/tar.gz/master | tar xzf - \
  && mv KnownReactions-master/ Reactions

# Add Yourls plugin
RUN  curl -s https://codeload.github.com/danito/KnownYourls/tar.gz/master | tar xzf - \
  && mv KnownYourls-master/ Yourls

# Add Journal plugin
RUN curl -s https://codeload.github.com/andrewgribben/KnownJournal/tar.gz/master | tar xzf - \
  && mv KnownJournal-master/ Journal

# Add Mastodon plugin
RUN  curl -s https://codeload.github.com/danito/KnownMastodon/tar.gz/master | tar xzf - \
  && mv KnownMastodon-master/ Mastodon

# Clean-up
RUN rm -rf /var/lib/apt/lists/* && apt-get -yq clean

# Set up container entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 700 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

HEALTHCHECK CMD curl --fail http://localhost || exit 1

# Expose Apache port and run Apache
EXPOSE 80
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
