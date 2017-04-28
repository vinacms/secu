#!/usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=cms
DBUSER=root
DBPASSWD=root
GITHUB_TOKEN=381936937f91ec41f6d0bc1bd1215a340017aa7e

echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server
apt-get install unzip

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -u$DBUSER -p$DBPASSWD -e "CREATE DATABASE $DBNAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -u$DBUSER -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'"

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-mbstring php-xml php-intl php-sqlite3 php-pgsql php-memcache memcached php-opcache php-apcu

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite
echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Restarting Services ---\n"
service apache2 restart
service mysql restart

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
