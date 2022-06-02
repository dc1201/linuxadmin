#!/bin/bash

#----------------------- APACHE --------------------------------

#informs the user that the script has started running
echo ">> Installing Apache HTTP Server <<"

#installs the Apache httpd server
yum install httpd -y

echo ">> Apache Web Server installed successfully! <<"

#starts the Apache
systemctl start httpd

echo ">> Apache has started <<"

#to allow traffic on the web server
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp

echo ">> Firewall will reload immediately to apply the changes <<"

#reloads the firewall 
firewall-cmd --reload

#enables the Apache to start on boot
systemctl enable httpd


#----------------------- PHP -----------------------------------

echo ">> Installation of PHP Apache Modules will now start <<"

#installs repositories to upgrade to upper version of php
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y

#installs specific version of php 
yum install yum-utils -y
yum-config-manager --enable remi-php56 

#installs php along with packages and modules
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y

echo ">> Restarting Apache server to apply the changes.... <<"

#restarts apache web server and checks the status
systemctl restart httpd
systemctl status httpd

echo ">> Succesfully applied the changes! <<"

echo "<?php phpinfo(); ?>" > /var/www/html/index.php

echo " >> Test the PHP Processing on the Web Server by visiting http://your_server_IP_address/ <<"


#----------------------- MariaDb --------------------------------

echo ">> Installing MariaDB <<"

#installs mariadb
yum install mariadb-server mariadb -y

echo ">> MariaDB installed successfully! <<"

#starts mariadb
systemctl start mariadb

echo ">> MariaDB started successfully! <<"

#setup database security or password and used the EOF operator to automate the input
mysql_secure_installation << EOF

y
password
password
y
y
y
y
EOF

#starts mariadb on boot and checks the status
systemctl enable mariadb
systemctl status mariadb

echo ">> Database system is now setup! <<"

