# Dockerfile for Known using MySQL/MariaDB
# initially forked from davesgonechina/docker-known
# inspired by ehdr/known and indiepaas/known

FROM debian:latest

LABEL description="Image for Known (withknown.com) using MySQL/MariaDB as backend" \
      version="githead" \
      authors="Bjoern Stierand <bjoern-known@innovention.de>"

ENV known_release 0.9.9

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
		libapache2-mod-php \
		php-curl \
		php-gd \
		php-mysql \
		php-xmlrpc \
    php-mbstring \
    php-xml \
    mysql-client \
		unzip \
    curl

# Configure Apache
RUN cd /etc/apache2/mods-enabled \
	&& ln -s ../mods-available/rewrite.load .

# Download and extract Known distribution
RUN mkdir -p /var/www/known \
  && cd /var/www/known \
#  && curl -o known.zip http://assets.withknown.com/releases/known-${known_release}.zip \
  && curl -ko known.zip https://codeload.github.com/idno/Known/zip/master \
  && unzip known.zip \
  && mv Known-master/* /var/www/known \
  && mv Known-master/.htaccess /var/www/known \
  && rm Known-master/.gitignore \
  && rm Known-master/.travis.yml \
  && ls Known-master \
  && rmdir Known-master \
  && rm known.zip

# Configure Known
COPY config.ini /var/www/known/
COPY apache2/sites-available/known.conf /etc/apache2/sites-available/

RUN cd /var/www/known \
	&& chmod 644 config.ini \
	# && mv htaccess.dist .htaccess \
	&& chown -R www-data:www-data /var/www/known/ \
  && cd /etc/apache2/sites-enabled \
	&& chmod 644 ../sites-available/known.conf \
	&& rm -f 000-default.conf \
	&& ln -s ../sites-available/known.conf .

# Add Facebook plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso facebook.zip https://codeload.github.com/idno/Facebook/zip/master \
  && unzip -qq facebook.zip \
  && mv Facebook-master/ Facebook \
  && rm facebook.zip

# Add Twitter plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso twitter.zip https://codeload.github.com/idno/Twitter/zip/master \
  && unzip -qq twitter.zip \
  && mv Twitter-master/ Twitter \
  && rm twitter.zip

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

# Add Flickr plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso flickr.zip https://codeload.github.com/idno/Flickr/zip/master \
  && unzip -qq flickr.zip \
  && mv Flickr-master/ Flickr \
  && rm flickr.zip

# Add Markdown plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso markdown.zip https://codeload.github.com/idno/Markdown/zip/master \
  && unzip -qq markdown.zip \
  && mv Markdown-master/ Markdown \
  && rm markdown.zip

# Add Chrome plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso chrome.zip https://codeload.github.com/mapkyca/KnownChrome/zip/master \
  && unzip -qq chrome.zip \
  && mv KnownChrome-master/ Chrome \
  && rm chrome.zip

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

# Add SmallHeader plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso smallheader.zip https://codeload.github.com/egoexpress/known-smallheader/zip/master \
  && unzip -qq smallheader.zip \
  && mv known-smallheader-master/ SmallHeader \
  && rm smallheader.zip

# Add SmallHeader plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso shortprofile.zip https://codeload.github.com/egoexpress/known-shortprofile/zip/master \
  && unzip -qq shortprofile.zip \
  && mv known-shortprofile-master/ ShortProfile \
  && rm shortprofile.zip

# Add Pinboard plugin
RUN cd /var/www/known/IdnoPlugins \
  && curl -kso pinboard.zip https://codeload.github.com/egoexpress/known-pinboard/zip/master \
  && unzip -qq pinboard.zip \
  && mv known-pinboard-master/ Pinboard \
  && rm pinboard.zip

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
ADD https://github.com/danito/KnownMastodon/archive/master.zip /var/www/known/IdnoPlugins/
RUN cd /var/www/known/IdnoPlugins && \
  unzip -qq master.zip && \
  mv KnownMastodon-master/ Mastodon && \
  rm -rf master.zip

# Clean-up
RUN rm -rf /var/lib/apt/lists/* && apt-get -yq clean

# Set up container entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 700 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose Apache port and run Apache
EXPOSE 80
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
