#!/bin/bash

set -e

ROOT=`pwd`
LIVE=0

OPT_COMPOSER=""

RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
NC='\e[0m' # No Color

# SETUP AND SANITY CHECKS
# =======================
while getopts l OPTION 2>/dev/null; do
    case $OPTION
    in
        l) LIVE=1;;
    esac
done

if [ $LIVE -eq 1 ]; then
  OPT_COMPOSER="--no-dev --optimize-autoloader"
fi

gem install scss-lint
npm install -g gulp

echo -e "${GREEN}Installing NPM dependencies…${NC}"
npm install

echo -e "${GREEN}Installing Composer dependencies…${NC}"
composer install --no-interaction $OPT_COMPOSER

echo -e "${GREEN}Building theme…${NC}"
cd "$ROOT/wp-content/themes/genesis-starter"
npm install
composer install --no-interaction $OPT_COMPOSER
gulp build