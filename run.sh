#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user_and_database.sh
	# Composer install the WebPanel-Core
	cd /app
	composer install
	php artisan key:generate
	if [ -z "${GITHUB_TOKEN}"]; then
		composer config github-oauth.github.com ${GITHUB_TOKEN}
	fi
	cd ../
else
    echo "=> Using an existing volume of MySQL"
fi

# Composer update the WebPanel-Core
chmod -R www-data /app
chgrp -R www-data /app
chmod 777 /app/storage

exec supervisord -n

cd /app
composer update
php artisan migrate --force
cd ../