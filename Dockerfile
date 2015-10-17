FROM ubuntu:trusty

MAINTAINER davesgonechina

RUN apt-get update

# ENV HOME /root
# ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# ENV DEBIAN_FRONTEND noninteractive
# RUN ssh-keygen -f /root/.ssh/id_rsa -q -N ""

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
# - mongo or mysql
# - reflection (included in libapache2-mod-php5)
# - session (included in libapache2-mod-php5)
# - xmlrpc
RUN apt-get -yq  --no-install-recommends install \
		apache2 \
		libapache2-mod-php5 \
		php5-curl \
		php5-gd \
		php5-mysql \
		php5-xmlrpc \
		git

# Configure Apache
RUN cd /etc/apache2/mods-enabled \
	&& ln -s ../mods-available/rewrite.load .

# Configure Git
RUN git config --global http.sslverify false

# Install Known
RUN apt-get -yq  --no-install-recommends install \
		curl \
		mysql-client
RUN mkdir -p /var/www/known \
	&& git clone https://github.com/idno/Known.git /var/www/known

# Configure Known
COPY config.ini /var/www/known/
RUN cd /var/www/known \
	&& chmod 644 config.ini \
	&& mv htaccess.dist .htaccess \
	&& chown -R root:www-data /var/www/known/

COPY apache2/sites-available/known.conf /etc/apache2/sites-available/
RUN cd /etc/apache2/sites-enabled \
	&& chmod 644 ../sites-available/known.conf \
	&& rm -f 000-default.conf \
	&& ln -s ../sites-available/known.conf .

#Add plugins
RUN cd /var/www/known/IdnoPlugins \
	&& git clone https://github.com/idno/Facebook.git \
	&& git clone https://github.com/idno/Twitter.git \
	&& git clone https://github.com/idno/Markdown.git \
	&& git clone https://github.com/idno/Diigo.git \
	&& git clone https://github.com/idno/S3.git \
	&& git clone https://github.com/mapkyca/KnownChrome.git \
	&& git clone https://github.com/idno/SoundCloud.git \
	&& git clone https://github.com/mapkyca/KnownLinkedin \
	&& mv /var/www/known/IdnoPlugins/KnownLinkedin/LinkedIn /var/www/known/IdnoPlugins \
	&& rm -r /var/www/known/IdnoPlugins/KnownLinkedin

# Clean-up
RUN rm -rf /var/lib/apt/lists/*

# Set up container entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 700 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


EXPOSE 80
CMD ["apache2", "-DFOREGROUND"]
