# Dockerfile for Known using MySQL
# initially forked from davesgonechina/docker-known
# inspired by ehdr/known and indiepaas/known

FROM debian:latest

MAINTAINER Bjoern Stierand <bjoern-known@innovention.de>

LABEL description="Image for Known (withknown.com) using MySQL as backend" \
      version="1.3"

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
RUN apt-get update && apt-get -yq --no-install-recommends install \
		apache2 \
		libapache2-mod-php5 \
		php5-curl \
		php5-gd \
		php5-mysql \
		php5-xmlrpc \
    mysql-client \
		unzip

# Configure Apache
RUN cd /etc/apache2/mods-enabled \
	&& ln -s ../mods-available/rewrite.load .

# Create Known directory
RUN mkdir -p /var/www/known \
	&& cd /var/www/known

# Download and extract Known distribution
ADD http://assets.withknown.com/releases/known-latest.zip /var/www/known/
RUN cd /var/www/known && \
  unzip -qq known-latest.zip && \
  rm known-latest.zip

# Configure Known
COPY config.ini /var/www/known/
RUN cd /var/www/known && \
	chmod 644 config.ini && \
	mv htaccess.dist .htaccess && \
	chown -R www-data:www-data /var/www/known/

COPY apache2/sites-available/known.conf /etc/apache2/sites-available/
RUN cd /etc/apache2/sites-enabled && \
	chmod 644 ../sites-available/known.conf && \
	rm -f 000-default.conf && \
	ln -s ../sites-available/known.conf .

# Add Facebook plugin
ADD https://github.com/idno/Facebook/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Facebook-master/ Facebook && \
  rm master.zip

# Add Twitter plugin
ADD https://github.com/idno/Twitter/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Twitter-master/ Twitter && \
  rm master.zip

# Add SoundCloud plugin
ADD https://github.com/idno/SoundCloud/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv SoundCloud-master/ SoundCloud && \
  rm master.zip

# Add WordPress plugin
ADD https://github.com/idno/WordPress/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv WordPress-master/ WordPress && \
  rm master.zip

# Add Diigo plugin
ADD https://github.com/idno/Diigo/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Diigo-master/ Diigo && \
  rm master.zip

# Add Foursquare plugin
ADD https://github.com/idno/Foursquare/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Foursquare-master/ Foursquare && \
  rm master.zip

# Add Flickr plugin
ADD https://github.com/idno/Flickr/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Flickr-master/ Flickr && \
  rm master.zip

# Add Markdown editor plugin
ADD https://github.com/idno/Markdown/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Markdown-master/ Markdown && \
  rm master.zip

# Add Chrome plugin
ADD https://github.com/mapkyca/KnownChrome/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv KnownChrome-master/Chrome Chrome && \
  rm -rf master.zip KnownChrome-master

# Add Pushover plugin
ADD https://github.com/timmmmyboy/Pushover/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv Pushover-master/ Pushover && \
  rm -rf master.zip

# Add Reactions plugin
ADD https://github.com/kylewm/KnownReactions/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv KnownReactions-master/ Reactions && \
  rm -rf master.zip

# Add SmallHeader plugin
ADD https://github.com/egoexpress/known-smallheader/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv known-smallheader-master/ SmallHeader && \
  rm -rf master.zip

# Add ShortProfile plugin
ADD https://github.com/egoexpress/known-shortprofile/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv known-shortprofile-master/ ShortProfile && \
  rm -rf master.zip

# Add Pinboard plugin
ADD https://github.com/egoexpress/known-pinboard/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv known-pinboard-master/ Pinboard && \
  rm -rf master.zip

# Add Chrome plugin
ADD https://github.com/danito/KnownYourls/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv KnownYourls-master/Yourls Yourls && \
  rm -rf master.zip KnownYourls-master

# Clean-up
RUN rm -rf /var/lib/apt/lists/* && apt-get -yq clean

# Set up container entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 700 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose Apache port and run Apache
EXPOSE 80
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
