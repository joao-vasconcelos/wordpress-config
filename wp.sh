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
echo -e "Enter the domain for this host (ex: mydomain.com): "
read domain




# # #
# Update apt
echo -e "Updating apt..."
apt-get update;



# # #
# Install required packages
echo -e "${YELLOW}Checking required packages...${NC}"
apt-get install --yes apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip nano wget curl
echo -e "${GREEN}Packages updated!${NC}"



# # #
# Setting RAM Swap
echo -e "Setting up RAM swap..."

RAM="`free -m | grep Mem | awk '{print $2}'`"
swap_allowed=$(($RAM * 2))
swap=$swap_allowed"M"
fallocate -l $swap /var/swap.img
chmod 600 /var/swap.img
mkswap /var/swap.img
swapon /var/swap.img

echo -e "${GREEN}RAM detected: $RAM
Swap was created: $swap${NC}"
sleep 3



# # #
# Configure Apache2 & Certbot HTTPS
echo -e "${YELLOW}Configuring Apache & LetsEncrypt using certbot...${NC}"

cat > /etc/apache2/sites-available/000-default-temp.conf <<EOL
<VirtualHost *:80>
  
  ServerName $domain
  ServerAlias www.$domain
  ServerAdmin webmaster@localhost
  
  DocumentRoot /srv/www/html

  <Directory /srv/www/html/>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

</VirtualHost>
EOL

mv /etc/apache2/sites-available/000-default-temp.conf /etc/apache2/sites-available/000-default.conf
sudo a2dissite 000-default
sudo a2ensite 000-default
sudo service apache2 reload
sleep 3

sudo snap install core
sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
certbot run -n --apache --agree-tos -d $domain,www.$domain -m noreply@$domain --redirect
sudo service apache2 reload
echo -e "${GREEN}Apache & LetsEncrypt was configured by Certbot!${NC}"



# # #
# Install wordpress
echo -e "${YELLOW}Installing Wordpres...${NC}"
mkdir -p /srv/www/html
chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
mv /srv/www/wordpress/* /srv/www/html/
rm -R /srv/www/wordpress

# # #
# Creating .htaccess file
echo -e "${YELLOW}Creating .htaccess file...${NC}"
sleep 3
cat > /srv/www/html/.htaccess <<EOL
# BEGIN WordPress

RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

# END WordPress
EOL

chmod 644 /srv/www/html/.htaccess

echo -e "${GREEN}.htaccess file was succesfully created!${NC}"




# # #
# Configuring MySQL
echo -e "${GREEN}Setting up MySQL and wp-config.php...${NC}"
db_pass=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')
mysql --user=root --password=$db_pass <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
ALTER DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat > /srv/www/html/wp-config.php <<EOL
<?php

define('DB_NAME', 'wordpress');

define('DB_USER', 'wordpress');

define('DB_PASSWORD', '$db_pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',         '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('SECURE_AUTH_KEY',  '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('LOGGED_IN_KEY',    '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('NONCE_KEY',        '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('AUTH_SALT',        '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('SECURE_AUTH_SALT', '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('LOGGED_IN_SALT',   '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');
define('NONCE_SALT',       '$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n')');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL

echo -e "${GREEN}Database and wp-config.php were created & configured!${NC}"



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
echo -e "${GREEN}You can now visit < https://$domain > to finish setting up Wordpress.${NC}"
exit 1