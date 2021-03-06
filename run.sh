#!/usr/env bash

set -ex;

mysql.server start

DB_NAME=${1-woodev}
DB_USER=${2-root}
DB_PASS=$3
PORT=8080
WP_PATH=$(pwd)/www
WP_TITLE='Welcome to the WooCommerce'
WP_DESC='Hello World!'
DUMMY_DATA="on"
DEV_PLUGIN="on"

if [ -e "$WP_PATH/wp-config.php" ]; then
    open http://127.0.0.1:$PORT
    wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
    exit 0
fi

if ! wp --info ; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    rm -fr bin && mkdir bin
    mv wp-cli.phar wp
    chmod 755 wp
fi

echo "path: www" > $(pwd)/wp-cli.yml

if [ $DB_PASS ]; then
    echo "DROP DATABASE IF EXISTS $DB_NAME;" | mysql -u$DB_USER -p$DB_PASS
    echo "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;" | mysql -u$DB_USER -p$DB_PASS
else
    echo "DROP DATABASE IF EXISTS $DB_NAME;" | mysql -u$DB_USER
    echo "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;" | mysql -u$DB_USER
fi

wp core download --path=$WP_PATH --locale=ja --force

if [ $DB_PASS ]; then
wp core config \
--dbhost=localhost \
--dbname="$DB_NAME" \
--dbuser="$DB_USER" \
--dbpass="$DB_PASS" \
--dbprefix=wp_ \
--locale=ja \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'WP_DEBUG', true );
define( 'WP_MAILCATCHER', true );
PHP
else
wp core config \
--dbhost=localhost \
--dbname=$DB_NAME \
--dbuser=$DB_USER \
--dbprefix=wp_ \
--locale=ja \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'WP_DEBUG', true );
define( 'WP_MAILCATCHER', true );
PHP
fi

wp core install \
--url=http://127.0.0.1:$PORT \
--title="WordPress" \
--admin_user="admin" \
--admin_password="admin" \
--admin_email="admin@example.com"

wp rewrite structure "/%category%/%post_id%"

wp option update blogname "$WP_TITLE"
wp option update blogdescription "$WP_DESC"

if [ -e "provision-post.sh" ]; then
    bash provision-post.sh
fi

wp plugin install woocommerce --activate
wp plugin delete akismet hello wp-multibyte-patch

if [ $DEV_PLUGIN = "on"]; then
    wp plugin install show-current-template admin-bar-id-menu simply-show-ids duplicate-post mailcatcher --activate

if [ $DUMMY_DATA = "on" ]; then
    wp plugin install wordpress-importer --activate
    wp import --authors=create test/sample_products.xml
else
  echo "not import dummy data"
fi

open http://127.0.0.1:$PORT
wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
