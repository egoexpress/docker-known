# Dockerfile for Known using MySQL/MariaDB
# initially forked from davesgonechina/docker-known
# inspired by ehdr/known and indiepaas/known

FROM ubuntu:focal

LABEL description="Image for Known (withknown.com) using MySQL/MariaDB as backend" \
      version="githead" \
      authors="Bjoern Stierand <bjoern-known@innovention.de>"

ENV known_release_url http://assets.withknown.com/releases/known-0.9.9.zip
ENV known_git_url https://codeload.github.com/idno/Known/zip/master
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

# install all required packages
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
		  apache2 \
		  composer \
		  libapache2-mod-php7.4 \
		  php7.4-curl \
		  php7.4-gd \
		  php7.4-mysql \
      php7.4-xmlrpc \
      php7.4-mbstring \
      php7.4-xml \
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
  && curl -ko known.zip ${known_git_url} \
  && unzip known.zip \
  && mv known-master/* /var/www/known \
  && mv known-master/.htaccess /var/www/known \
  && rm known-master/.gitignore \
  && rm known-master/.travis.yml \
  && rm known-master/.babelrc \
  && rm -r known-master/.github \
  && rmdir known-master \
  && rm known.zip

# Configure Known
COPY config.ini /var/www/known/
COPY apache2/sites-available/known.conf /etc/apache2/sites-available/

WORKDIR /var/www/known

RUN chmod 644 config.ini \
	&& composer install \
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

# Add Facebook plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso facebook.zip https://codeload.github.com/idno/Facebook/zip/master \
  && unzip -qq facebook.zip \
  && mv Facebook-master/ Facebook \
  && rm facebook.zip

# Add SoundCloud plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso soundcloud.zip https://codeload.github.com/idno/SoundCloud/zip/master \
  && unzip -qq soundcloud.zip \
  && mv SoundCloud-master/ SoundCloud \
  && rm soundcloud.zip

# Add WordPress plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso wordpress.zip https://codeload.github.com/idno/WordPress/zip/master \
  && unzip -qq wordpress.zip \
  && mv WordPress-master/ WordPress \
  && rm wordpress.zip

# Add Diigo plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso diigo.zip https://codeload.github.com/idno/Diigo/zip/master \
  && unzip -qq diigo.zip \
  && mv Diigo-master/ Diigo \
  && rm diigo.zip

# Add Foursquare plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso foursquare.zip https://codeload.github.com/idno/Foursquare/zip/master \
  && unzip -qq foursquare.zip \
  && mv Foursquare-master/ Foursquare \
  && rm foursquare.zip

# Add Markdown plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso markdown.zip https://codeload.github.com/idno/Markdown/zip/master \
  && unzip -qq markdown.zip \
  && mv Markdown-master/ Markdown \
  && rm markdown.zip

# Add Pushover plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso pushover.zip https://codeload.github.com/timmmmyboy/Pushover/zip/master \
  && unzip -qq pushover.zip \
  && mv Pushover-master/ Pushover \
  && rm pushover.zip

# Add Reactions plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso reactions.zip https://codeload.github.com/kylewm/KnownReactions/zip/master \
  && unzip -qq reactions.zip \
  && mv KnownReactions-master/ Reactions \
  && rm reactions.zip

# Add Yourls plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso yourls.zip https://codeload.github.com/danito/KnownYourls/zip/master \
  && unzip -qq yourls.zip \
  && mv KnownYourls-master/ Yourls \
  && rm yourls.zip

# Add Journal plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso journal.zip https://codeload.github.com/andrewgribben/KnownJournal/zip/master \
  && unzip -qq journal.zip \
  && mv KnownJournal-master/ Journal \
  && rm journal.zip

# Add Mastodon plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso mastodon.zip https://codeload.github.com/danito/KnownMastodon/zip/master \
  && unzip -qq mastodon.zip \
  && mv KnownMastodon-master/ Mastodon \
  && rm mastodon.zip

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
