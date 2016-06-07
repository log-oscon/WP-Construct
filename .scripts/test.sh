#!/bin/bash

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPTS_DIR" && cd .. && pwd)

if [ -z "$WP_TESTS_DB_NAME" ]; then
  WP_TESTS_DB_NAME=wordpress_unit_tests
fi

if [ -z "$WP_TESTS_DB_USER" ]; then
  # Codeship stores its MySQL user in the MYSQL_USER env variable.
  WP_TESTS_DB_USER=$MYSQL_USER
fi

if [ -z "$WP_TESTS_DB_USER" ]; then
  WP_TESTS_DB_USER=wp
fi

if [ -z "$WP_TESTS_DB_PASSWORD" ]; then
  # Codeship stores its MySQL password in the MYSQL_PASSWORD env variable.
  WP_TESTS_DB_PASSWORD=$MYSQL_PASSWORD
fi

if [ -z "$WP_TESTS_DB_PASSWORD" ]; then
  WP_TESTS_DB_PASSWORD=wp
fi

cd $SCRIPTS_DIRg

bash install-wp-tests.sh $WP_TESTS_DB_NAME $WP_TESTS_DB_USER $WP_TESTS_DB_PASSWORD

cd $ROOT_DIR

find . -name '*.php' -not -path "*/vendor/*" -print0 | xargs -0 -n 1 -P 4 php -l
