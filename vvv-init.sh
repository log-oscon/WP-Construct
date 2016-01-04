#!/bin/bash

## CONFIGURATION ##

TITLE="WordPress Genesis Boilerplate"
URL="genesis.wordpress.dev"
DATABASE="genesis_wordpress_dev"
ADMIN_EMAIL="engenharia@log.pt"
THEME="genesis-starter"
PLUGINS=(autoptimize redis-cache wordpress-seo wordpress-importer wp-hydra)

## That's it! You don't need to change anything below this line! ##

## FUNCTIONS ##

noroot() {
  sudo -EH -u vagrant HTTP_HOST="${URL}" "$@";
}

## PROVISIONING ##

echo "Setting up a local ${TITLE} project for development..."

sudo apt-get -y install graphicsmagick redis-server php5-redis
sudo service php5-fpm restart
sudo gem install scss_lint
sudo npm install -g gulp

noroot ./.build.sh

if ! $(noroot wp core is-installed); then

    echo " * Downloading WordPress"

    noroot wp core download

    echo " * Creating database schema ${DATABASE}"

    mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DATABASE}"
    mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO wp@localhost IDENTIFIED BY 'wp';"

    echo " * Configuring WordPress"

    WP_CACHE_KEY_SALT=`date +%s | sha256sum | head -c 64`

    noroot wp core config --dbname="${DATABASE}" --dbuser=wp --dbpass=wp --extra-php <<PHP

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
@ini_set( 'display_errors', 0 );
define( 'SAVEQUERIES', false );
define( 'JETPACK_DEV_DEBUG', true );

define( 'WP_CACHE', true );
define( 'WP_CACHE_KEY_SALT', '$WP_CACHE_KEY_SALT' );

define( 'WP_ENV', 'development' );
PHP

    echo " * Setting up \"$TITLE\" at $URL"

    noroot wp core install --url="$URL" --title="$TITLE" --admin_user=admin --admin_password=password --admin_email="$ADMIN_EMAIL"

    ## ACTIVATING COMPONENTS ##

    echo " * Activating the default theme"

    noroot wp theme activate ${THEME}

    echo " * Activating plugins"

    noroot wp plugin activate ${PLUGINS[*]}

    echo " * Importing test content"

    noroot curl -OLs https://raw.githubusercontent.com/manovotny/wptest/master/wptest.xml
    noroot wp import wptest.xml --authors=create
    noroot rm wptest.xml
fi

## UPDATING COMPONENTS ##

echo " * Updating WordPress"

noroot wp core update
noroot wp core update-db

echo "All done!"
