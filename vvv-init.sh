#!/bin/bash

## CONFIGURATION ##

TITLE="WordPress Genesis Boilerplate"
URL="genesis.wordpress.dev"
DATABASE="genesis_wordpress_dev"
ADMIN_EMAIL="engenharia@log.pt"

THEME="genesis-starter"

PLUGINS=(autoptimize wordpress-seo)

DEV_PLUGINS=(wp-hydra)

## That's it! You don't need to change anything below this line! ##

## PROVISIONING ##

echo "Setting up a local ${TITLE} project for development..."

su vagrant -c "./.build.sh"

if ! $(wp core is-installed); then

    echo " * Downloading WordPress"

    wp core download

    echo " * Creating database schema ${DATABASE}"

    mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DATABASE}"
    mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO wp@localhost IDENTIFIED BY 'wp';"

    echo " * Configuring WordPress"

    WP_CACHE_KEY_SALT=`date +%s | sha256sum | head -c 64`

    wp core config --dbname="${DATABASE}" --dbuser=wp --dbpass=wp --extra-php <<PHP

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
@ini_set( 'display_errors', 0 );
define( 'SAVEQUERIES', false );
define( 'JETPACK_DEV_DEBUG', true );

define( 'WP_CACHE', true );
define( 'WP_CACHE_KEY_SALT', '$WP_CACHE_KEY_SALT' );

\$redis_server = array( 'host' => '127.0.0.1', 'port' => 6379 );

define( 'WP_ENV', 'development' );
PHP

    echo " * Setting up \"$TITLE\" at $URL"

    wp core install --url="$URL" --title="$TITLE" --admin_user=admin --admin_password=password --admin_email="$ADMIN_EMAIL"

    echo " * Configuring pretty permalinks"

    wp option update permalink_structure "/%postname%/"

    echo " * Importing test content"

    curl -OLs https://raw.githubusercontent.com/manovotny/wptest/master/wptest.xml
    wp plugin install wordpress-importer
    wp plugin activate wordpress-importer
    wp import wptest.xml --authors=create
    rm wptest.xml

fi

## OBJECT CACHE ##

echo " * Setting up object cache"

sudo apt-get -y install redis-server php5-redis
sudo service php5-fpm restart

wp plugin install wp-redis
wp plugin update wp-redis
cp wp-content/plugins/wp-redis/object-cache.php wp-content/object-cache.php

touch wp-content/advanced-cache.php

## UPDATING COMPONENTS ##

echo " * Updating WordPress"

wp core update
wp core update-db

## ACTIVATING COMPONENTS ##

echo " * Activating the default theme"

wp theme activate ${THEME}

echo " * Activating plugins"

wp plugin activate ${PLUGINS[*]}

echo " * Installing and activating development plugins"

wp plugin activate ${DEV_PLUGINS[*]}

echo "All done!"
