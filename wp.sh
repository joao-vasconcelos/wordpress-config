#!/bin/bash

#######################################################
# Script to configure Server, WebServer and WordPress #
#######################################################



# # #
# Color Settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color



# # #
# Script init
clear
echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!"



# # #
# Update apt
echo -e "Updating apt..."
apt-get update;



# # #
# Install required packages
echo -e "${YELLOW}Checking packages...${NC}"

echo -e "${YELLOW}Installing 'apache2'...${NC}"
apt-get install apache2 --yes;

echo -e "${YELLOW}Installing 'ghostscript'...${NC}"
apt-get install ghostscript --yes;

echo -e "${YELLOW}Installing 'libapache2-mod-php'...${NC}"
apt-get install libapache2-mod-php --yes;

echo -e "${YELLOW}Installing 'mysql-server'...${NC}"
apt-get install mysql-server --yes;

echo -e "${YELLOW}Installing 'php'...${NC}"
apt-get install php --yes;

echo -e "${YELLOW}Installing 'php-bcmath'...${NC}"
apt-get install php-bcmath --yes;

echo -e "${YELLOW}Installing 'php-curl'...${NC}"
apt-get install php-curl --yes;

echo -e "${YELLOW}Installing 'php-imagick'...${NC}"
apt-get install php-imagick --yes;

echo -e "${YELLOW}Installing 'php-intl'...${NC}"
apt-get install php-intl --yes;

echo -e "${YELLOW}Installing 'php-json'...${NC}"
apt-get install php-json --yes;

echo -e "${YELLOW}Installing 'php-mbstring'...${NC}"
apt-get install php-mbstring --yes;

echo -e "${YELLOW}Installing 'php-mysql'...${NC}"
apt-get install php-mysql --yes;

echo -e "${YELLOW}Installing 'php-xml'...${NC}"
apt-get install php-xml --yes;

echo -e "${YELLOW}Installing 'php-zip'...${NC}"
apt-get install php-zip --yes;

echo -e "${YELLOW}Installing 'nano'...${NC}"
apt-get install nano --yes;

echo -e "${YELLOW}Installing 'wget'...${NC}"
apt-get install wget --yes;

echo -e "${YELLOW}Installing 'curl'...${NC}"
apt-get install curl --yes;

echo -e "${GREEN}Packages updated!${NC}"




# # #
# Setting RAM Swap
echo -e "On next step we create SWAP (it should be your RAM x2)..."

RAM="`free -m | grep Mem | awk '{print $2}'`"
swap_allowed=$(($RAM * 2))
swap=$swap_allowed"M"
fallocate -l $swap /var/swap.img
chmod 600 /var/swap.img
mkswap /var/swap.img
swapon /var/swap.img

echo -e "${GREEN}RAM detected: $RAM
Swap was created: $swap${NC}"
sleep 5





# # #
# Install wordpress
echo -e "${YELLOW}Installing Wordpres...${NC}"
mkdir -p /srv/www
chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www




# # #
# Configure Apache
echo -e "${YELLOW}Configuring Apache2...${NC}"
rm -R /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf <<EOL
  <VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
      <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
      </Directory>
      <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
      </Directory>
  </VirtualHost>
EOL

sudo a2dissite 000-default
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo service apache2 reload

echo -e "${GREEN}Apache2 config was updated!${NC}"
echo -e "${GREEN}New config file was created: /etc/apache2/sites-available/wordpress.conf${NC}"
echo -e "${GREEN}Website was activated & apache2 service reloaded!${NC}"



# # #
# Creating .htaccess file
echo -e "${YELLOW}Creating .htaccess file...${NC}"
sleep 3
cat > /srv/www/wordpress/.htaccess <<EOL
# BEGIN WordPress

RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

# END WordPress
EOL

chmod 644 /srv/www/wordpress/.htaccess

echo -e "${GREEN}.htaccess file was succesfully created!${NC}"




# # #
# Configuring MySQL
echo -e "${GREEN}Setting up MySQL and wp-config.php...${NC}"
echo -e "Set password for 'wordpress' database user: "
read db_pass

mysql -u root -p <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
ALTER DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat > /srv/www/wordpress/wp-config.php <<EOL
<?php

define('DB_NAME', 'wordpress');

define('DB_USER', 'wordpress');

define('DB_PASSWORD', '$db_pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',         'wordpress');
define('SECURE_AUTH_KEY',  'wordpress');
define('LOGGED_IN_KEY',    'wordpress');
define('NONCE_KEY',        'wordpress');
define('AUTH_SALT',        'wordpress');
define('SECURE_AUTH_SALT', 'wordpress');
define('LOGGED_IN_SALT',   'wordpress');
define('NONCE_SALT',       'wordpress');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL

echo -e "${GREEN}Database and wp-config.php were succesfully created & configured!${NC}"



# # #
# Restart services
echo -e "${GREEN}Restarting services...${NC}"
service apache2 restart
service mysql restart
echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3



# # #
# End Script
echo -e "${GREEN}Installation & configuration succesfully finished! Thank you :)${NC}"
exit 1