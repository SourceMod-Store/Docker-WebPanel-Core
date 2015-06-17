FROM ubuntu:trusty
MAINTAINER Werner Maisl <werner@myhomenet.at>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt curl && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD composer_install.sh /composer_install.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.
ADD .env /.env

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD create_mysql_database.sh /create_mysql_database.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/SourceMod-Store/WebPanel-Core.git /app

# Download composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Link the app to /var/www/html
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Link .env to /var/www/html
RUN ln -s .env /var/www/html/.env

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
