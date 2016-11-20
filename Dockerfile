#Download base image ubuntu 16.04
FROM ubuntu:16.04

MAINTAINER rodwin lising <rodwinlising@gmail.com>

# Update Ubuntu Software repository
RUN apt-get update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y \
	nginx \
	php7.0-fpm \
	php7.0-cli \
    php7.0-common \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-pgsql \
    php7.0-sqlite \
    php7.0-sqlite3 \
    php7.0-zip \
    php7.0-memcached \
    php7.0-gd \
    pkg-config \
    php-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
    libsqlite3-dev \
    sqlite3 \
	supervisor \
	nodejs \
	nodejs-dev \
	npm \
	curl \
	git \
	postgresql-client

# Install gulp and bower with NPM
RUN npm install -g \
    gulp \
    bower

# Add a symbolic link for Node
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && echo "alias composer='/usr/local/bin/composer.phar'" >> ~/.bashrc

# Source the bash
RUN . ~/.bashrc

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable php-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

#Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

WORKDIR /var/www/html

# Configure Services and Port
COPY start.sh /start.sh
#CMD ["./start.sh"]
ENTRYPOINT ["/bin/bash", "/start.sh"] 
EXPOSE 80 443

