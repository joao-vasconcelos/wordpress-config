#!/bin/bash

#######################################################
# Script to configure Server, WebServer and WordPress #
#######################################################


#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


#Welcome message
clear
echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!"


echo -e "Updating apt..."
apt-get update;


#Checking packages
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

# echo -e "${YELLOW}Installing 'zip'...${NC}"
# apt-get install zip --yes;

# echo -e "${YELLOW}Installing 'mc'...${NC}"
# apt-get install mc --yes;

# echo -e "${YELLOW}Installing 'htop'...${NC}"
# apt-get install htop --yes;

# echo -e "${YELLOW}Installing 'fail2ban'...${NC}"
# apt-get install fail2ban --yes;



exit 1

#creating user
echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

  # echo -e "${YELLOW}Please, enter new username: ${NC}"
  # read username
  # echo -e "${YELLOW}Please enter website name: ${NC}"
  # read websitename
  # groupadd wordpress
  # adduser --home /var/www/html --ingroup wordpress wordpress
  mkdir /srv/www/wordpress
  # chown -R wordpress:wordpress /var/www/html
  echo -e "${GREEN}User, group and home folder were succesfully created!"


#configuring apache2
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

# read -r -p "Do you want to configure Apache2 automatically? [y/N] " response

  # echo -e "Please, provide us with your domain name: "
  # read domain_name
  # echo -e "Please, provide us with your email: "
  # read domain_email
  cat >/etc/apache2/sites-available/wordpress.conf <<EOL
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
	a2dissite 000-default
    a2ensite wordpress
    service apache2 restart
    # P_IP="`wget http://ipinfo.io/ip -qO -`"

    echo -e "${GREEN}Apache2 config was updated!
    New config file was created: /etc/apache2/sites-available/wordpress.conf
    Website was activated & apache2 service reloaded!
    ${NC}"

#downloading WordPress, unpacking, adding basic pack of plugins, creating .htaccess with optimal & secure configuration
echo -e "${YELLOW}On this step we going to download latest version of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"

read -r -p "Do you want to install WordPress & automatically set optimal and secure configuration with basic set of plugins? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
  
  wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip

  echo -e "Unpacking WordPress into website home directory..."
  sleep 5
  unzip /tmp/wordpress.zip -d /srv/www/wordpress2/
  mv /srv/www/wordpress2/* /srv/www/wordpress
  rm -rf /srv/www/wordpress2
  rm /tmp/wordpress.zip
  mkdir /srv/www/wordpress/wp-content/uploads
  chmod -R 777 /srv/www/wordpress/wp-content/uploads

  echo -e "Now we going to download some useful plugins:
  1. Google XML Sitemap generator
  2. Social Networks Auto Poster
  3. Add to Any
  4. Easy Watermark"
  sleep 7
  
  # SITEMAP="`curl https://wordpress.org/plugins/google-sitemap-generator/ | grep https://downloads.wordpress.org/plugin/google-sitemap-generator.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  # wget $SITEMAP -O /tmp/sitemap.zip
  # unzip /tmp/sitemap.zip -d /tmp/sitemap
  # mv /tmp/sitemap/* /var/www/$username/$websitename/www/wp-content/plugins/

  # wget https://downloads.wordpress.org/plugin/social-networks-auto-poster-facebook-twitter-g.zip -O /tmp/snap.zip
  # unzip /tmp/snap.zip -d /tmp/snap
  # mv /tmp/snap/* /var/www/$username/$websitename/www/wp-content/plugins/

  # ADDTOANY="`curl https://wordpress.org/plugins/add-to-any/ | grep https://downloads.wordpress.org/plugin/add-to-any.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  # wget $ADDTOANY -O /tmp/addtoany.zip
  # unzip /tmp/addtoany.zip -d /tmp/addtoany
  # mv /tmp/addtoany/* /var/www/$username/$websitename/www/wp-content/plugins/

  # WATERMARK="`curl https://wordpress.org/plugins/easy-watermark/ | grep https://downloads.wordpress.org/plugin/easy-watermark.*.*.*.zip | awk '{print $3}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  # wget $WATERMARK -O /tmp/watermark.zip
  # unzip /tmp/watermark.zip -d /tmp/watermark
  # mv /tmp/watermark/* /var/www/$username/$websitename/www/wp-content/plugins/

  # rm /tmp/sitemap.zip /tmp/snap.zip /tmp/addtoany.zip /tmp/watermark.zip
  # rm -rf /tmp/sitemap/ /tmp/snap/ /tmp/addtoany/ /tmp/watermark/


  echo -e "Downloading of plugins finished! All plugins were transfered into /wp-content/plugins directory.${NC}"

        ;;
    *)

  echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}"

        ;;
esac

#creating of swap
echo -e "On next step we going to create SWAP (it should be your RAM x2)..."

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

#creation of secure .htaccess
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/srv/www/wordpress/.htaccess <<EOL
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

#cration of robots.txt
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/srv/www/wordpress/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

echo -e "${GREEN}File robots.txt was succesfully created!
Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3

chmod 755 /srv/www/wordpress/robots.txt

echo -e "${GREEN}Configuring fail2ban...${NC}"
sleep 3
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf-old
cat >/etc/fail2ban/jail.conf <<EOL
[DEFAULT]

ignoreip = 127.0.0.1/8
ignorecommand =
bantime  = 1200
findtime = 1200
maxretry = 3
backend = auto
usedns = warn
destemail = $domain_email
sendername = Fail2Ban
sender = fail2ban@localhost
banaction = iptables-multiport
mta = sendmail

# Default protocol
protocol = tcp
# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT
# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_mw)s

[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5

[ssh-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 5

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 5
EOL

service fail2ban restart

echo -e "${GREEN}fail2ban configuration finished!
fail2ban service was restarted, default confige backuped at /etc/fail2ban/jail.conf-old
Jails were set for: ssh bruteforce, ssh ddos, apache overflows${NC}"

sleep 5

echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
	StartServers			 1
	MinSpareServers		  1
	MaxSpareServers		 3
	MaxRequestWorkers	  10
	MaxConnectionsPerChild   3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
	StartServers			 1
	MinSpareThreads		 5
	MaxSpareThreads		 15
	ThreadLimit			 25
	ThreadsPerChild		 5
	MaxRequestWorkers	  25
	MaxConnectionsPerChild   200
</IfModule>
EOL

a2dismod status

echo -e "${GREEN}Configuration of apache mods was succesfully finished!
Restarting Apache & MySQL services...${NC}"

service apache2 restart
service mysql restart

echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3

echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
echo -e "Please, set username for database: "
read db_user
echo -e "Please, set password for database user: "
read db_pass

mysql -u root -p <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
ALTER DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat >/srv/www/wordpress/wp-config.php <<EOL
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

# chown -R wordpress:wordpress /var/www/$username
echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
sleep 3
echo -e "Installation & configuration succesfully finished."
