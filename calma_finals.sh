#!/bin/bash

#----------------------- APACHE --------------------------------

#informs the user that the script has started running


echo -e "\n=========================================="
echo "	Installing Apache HTTP Server"
echo -e "==========================================\n"

#installs the Apache httpd server
yum install httpd -y

echo -e "\n========================================================"
echo "	Apache Web Server installed successfully!"
echo -e "========================================================\n"

#starts the Apache
systemctl start httpd

echo -e "\n=========================================="
echo "	Apache has started "
echo -e "==========================================\n"


#to allow traffic on the web server
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp

echo -e "\n===================================================================="
echo "	Firewall will reload immediately to apply the changes"
echo -e "====================================================================\n"


#reloads the firewall 
firewall-cmd --reload

#enables the Apache to start on boot
systemctl enable httpd


#----------------------- PHP -----------------------------------

echo -e "\n============================================================"
echo "	Starting the installation of PHP Apache Modules"
echo -e "============================================================\n"

#installs repositories to upgrade to upper version of php
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y

#installs specific version of php 
yum install yum-utils -y
yum-config-manager --enable remi-php56 

#installs php along with packages and modules
yum install php php-mysql php-fpm php-mcrypt php-cli php-curl php-ldap php-zip php-fileinfo -y

echo -e "\n==============================================================="
echo "	Restarting Apache server to apply the changes.... "
echo -e "===============================================================\n"

#restarts apache web server and checks the status
systemctl restart httpd
systemctl status httpd

echo -e "\n============================================="
echo "	Succesfully applied the changes!"
echo -e "=============================================\n"

echo "<?php phpinfo(); ?>" > /var/www/html/index.php


echo -e "\n=================================================================================================="
echo "	Test the PHP Processing on the Web Server by visiting http://your_server_IP_address/ "
echo -e "==================================================================================================\n"

#----------------------- MariaDb --------------------------------


echo -e "\n================================"
echo "	Installing MariaDB "
echo -e "================================\n"

#installs mariadb
yum install mariadb-server mariadb -y

echo -e "\n============================================"
echo "	MariaDB installed successfully!"
echo -e "============================================\n"

#starts mariadb
systemctl start mariadb

echo -e "\n==========================================="
echo "	MariaDB started successfully! "
echo -e "===========================================\n"

#setup database security or password and used the EOF operator to automate the input
mysql_secure_installation << EOF

y
passwd
passwd
y
y
y
y
EOF


#starts mariadb on boot and checks the status
systemctl enable mariadb
systemctl status mariadb 

echo -e "\n=========================================="
echo "	Database system is now setup!"
echo -e "==========================================\n"

#----------------------- Automated Installation of WordPress Content Management System --------------------------------

echo -e "\n=========================================="
echo "	Verifying Installation"
echo -e "==========================================\n"

#checks the mariadb version
mysqladmin -u root -ppasswd version

echo -e "\n=========================================="
echo "	Creating Database...."
echo -e "==========================================\n"

#automates the database creation with the variables
mysql -u root -ppasswd << SQL
CREATE DATABASE wordpress;
CREATE USER dani@localhost IDENTIFIED BY 'passwd';
GRANT ALL PRIVILEGES ON wordpress.* TO dani@localhost IDENTIFIED BY 'passwd';
FLUSH PRIVILEGES;
SQL

echo -e "\n=============================================================="
echo "	Wordpress Database has been created successfully!"
echo -e "==============================================================\n"

echo -e "\n================================================"
echo "	Installing PHP module for Wordpress"
echo -e "================================================\n"

#installs the php module that will ensure wordpress will be able to resize images to create thumbnails
yum install php-gd -y

echo -e "\n=========================================="
echo "	Installing Necessary Packages"
echo -e "==========================================\n"

#installs wget to download files from web and tar to create and extract archive files
yum install wget tar -y

echo -e "\n=========================================================================="
echo "	Restarting Apache to recognize the new module and packages..."
echo -e "==========================================================================\n"

service httpd restart

echo -e "\n=========================================="
echo "	Installing Wordpress..."
echo -e "==========================================\n"

#downloads the latest wordpress and extracts it
cd ~ 
wget http://wordpress.org/latest.tar.gz  
tar xzvf latest.tar.gz 

echo -e "\n=========================================="
echo "	Installing Rsync..."
echo -e "==========================================\n"

#copies the content of latest.tar.gz to the directory of apache
yum install rsync -y
rsync -avP ~/wordpress/ /var/www/html/  

echo -e "\n==================================================================="
echo "	Creating a folder to store uploaded files to Wordpress"
echo -e "===================================================================\n"

#creates uploads folder
mkdir /var/www/html/wp-content/uploads

echo -e "\n======================================================================================"
echo "	Assigning correct ownership and permission to wordpress files and folders"
echo -e "======================================================================================\n"

#setting up the ownership and permission of wordpress files
chown -R apache:apache /var/www/html/*

echo -e "\n======================================================="
echo "	Setting up the configuration for Wordpress"
echo -e "=======================================================\n"

#copies the default config file to the file location of wordpress 
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php


#variables
dbname=wordpress
uname=dani
pswd=passwd

#automates the wordpress configurations
sed -i 's/database_name_here/'$dbname'/' /var/www/html/wp-config.php
sed -i 's/username_here/'$uname'/' /var/www/html/wp-config.php
sed -i 's/password_here/'$pswd'/' /var/www/html/wp-config.php

echo -e "\n=========================================="
echo "	Restarting the Apache Server"
echo -e "==========================================\n"

systemctl restart httpd

echo -e "\n================================================================================"
echo "	Please visit http://your_server_IP_address/ or server's domain name"
echo "	in your browser to complete your Wordpress site setup."
echo -e "================================================================================\n"

