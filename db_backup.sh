#!/bin/bash

echo -e "\n=========================================="
echo "	Creating Backups Folder"
echo -e "==========================================\n"

#creates folder to store database backup
mkdir /opt/backups

echo -e "\n=========================================="
echo "	Installing Gzip Package"
echo -e "==========================================\n"

#installs gzip to compress the db file backup
yum install gzip -y

echo -e "\n======================================================"
echo "	Creating the wordpress database backup..."
echo -e "======================================================\n"

#creating a backup for wordpress database and compressing the file. 
mysqldump -u dani -ppasswd --databases wordpress | gzip > /opt/backups/wordpress_`date '+%m-%d-%Y'`.sql.gz