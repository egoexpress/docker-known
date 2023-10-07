# Dockerfile for Known using MySQL/MariaDB
# initially forked from davesgonechina/docker-known
# inspired by ehdr/known and indiepaas/known

FROM ubuntu:jammy

LABEL description="Image for Known (withknown.com) using MySQL/MariaDB as backend" \
      version="1.5" \
      authors="Bjoern Stierand <bjoern-known@innovention.de>"

ENV branch 1.5
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
    apt-get -yq --no-install-recommends install \
      gnupg2 \
      apache2 \
      composer \
      libapache2-mod-php8.1 \
      php8.1-curl \
      php8.1-gd \
      php8.1-mysql \
      php8.1-xmlrpc \
      php8.1-mbstring \
      php8.1-xml \
      mysql-client \
      unzip \
      curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get -yq clean

# Configure Apache
RUN cd /etc/apache2/mods-enabled \
  && ln -s ../mods-available/rewrite.load . \
  && ln -s ../mods-available/headers.load .

# Download and extract Known distribution
RUN mkdir -p /var/www/known \
  && cd /var/www/known \
  && curl -s ${known_url} | tar -xzf - \
  && mv known-${branch}/* /var/www/known \
  && mv known-${branch}/.htaccess /var/www/known \
  && rm -r known-${branch}

# Configure Apache
COPY apache2/sites-available/known.conf /etc/apache2/sites-available/
COPY files/composer.json /var/www/known

# Configure Known
WORKDIR /var/www/known

# This adds a unique file that changes when the branch changes for cache busting
ADD https://api.github.com/repos/idno/known/git/refs/heads/$BRANCH version.json

COPY config.ini .

RUN chmod 644 config.ini \
  && composer update  --no-dev -o -a \
  && composer install --no-dev -o -a \
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
RUN curl -s https://codeload.github.com/idno/Facebook/tar.gz/dev | tar xzf - \
  && mv Facebook-dev/ Facebook

# Add SoundCloud plugin
RUN curl -s https://codeload.github.com/idno/SoundCloud/tar.gz/dev | tar xzf - \
  && mv SoundCloud-dev/ SoundCloud

# Add WordPress plugin
RUN curl -s https://codeload.github.com/idno/WordPress/tar.gz/dev | tar xzf - \
  && mv WordPress-dev/ WordPress

# Add Diigo plugin
RUN curl -s https://codeload.github.com/timmmmyboy/Diigo/tar.gz/master | tar xzf - \
  && mv Diigo-master/ Diigo

# Add Foursquare plugin
RUN  curl -s https://codeload.github.com/idno/Foursquare/tar.gz/dev | tar xzf - \
  && mv Foursquare-dev/ Foursquare

# Add Markdown plugin
RUN  curl -s https://codeload.github.com/idno/Markdown/tar.gz/dev | tar xzf - \
  && mv Markdown-dev/ Markdown

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

# Set up container entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 700 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

HEALTHCHECK CMD curl --fail http://localhost || exit 1

# Expose Apache port and run Apache
EXPOSE 80
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
