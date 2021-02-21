#!/bin/bash - 
#===============================================================================
#
#          FILE: start.sh
# 
#         USAGE: ./start.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@mobileum.com
#  ORGANIZATION: Mobileum
#       CREATED: 04/30/2017 22:08
# Last modified: Fri Feb 19, 2021  05:27PM
#      REVISION:  ---
#===============================================================================

# rpass=$( < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo; ) 


export PASS=${MYSQL_PASS:-PPAAssWW00RRdd}
echo $PASS > ~/mysql_password.txt
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
# Run mysqld and wait for it to start
# chown apache:apache -R /var/www/html

if [[ -f /etc/php5/apache2/php.ini ]]
then
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    	-e "s/^allow_url_include.*/allow_url_include = On/" \
    	-e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
else
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    	-e "s/^allow_url_include.*/allow_url_include = On/" \
    	-e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php.ini
fi
MYSQL_PASS=$PASS /root/bin/create_mysql_admin_user.sh

# mysql_* are deprecated...
cd /var/www/html
grep -r -i -l mysql_ *|sort|uniq|while read line
do
    sed -i 's/mysql_/mysqli_/g' $line
done

chown apache:apache /var/www/html/
chmod 777  /var/www/html/dvwa/DVWA-master/hackable/uploads  /var/www/html/dvwa/DVWA-master/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt /var/www/html/dvwa/DVWA-master/config

/root/bin/dvwa-install.sh
# Run DVNA
su - dvna -c node dvna.js &

# Run WebGoat
cd /root/webgoat
java -Djava.security.egd=file:/dev/urandom -jar  webwolf-8.1.0.jar --server.address=0.0.0.0 >/root/webwolf.log &
java -Djava.security.egd=file:/dev/urandom -jar  webgoat-server-8.1.0.jar --server.address=0.0.0.0 >/root/webgoat.log &


## Fix Bricks..
sed -i 's/mysqli_query(/mysqli_query($con,/' /var/www/html/owasp-bricks/bricks/config/setup.php

cd /var/www/html/owasp-bricks/bricks
grep -r -i -l mysqli_query *|while read line
do
    sed -i 's/mysqli_query(/mysqli_query($con,/' $line
done

## Setup mutillidae
sed -i '/DB_PASSWORD/ s/mutillidae/'$PASS'/' /var/www/html/mutillidae/includes/database-config.php


#Setup DVWS
cd /var/www/html/dvws
sed -i 's/localhost/127.0.0.1/g' instructions.php
sed -i "/127.0.0.1/ s/''/'$PASS'/" instructions.php
sed -i 's/localhost/127.0.0.1/g' about/instructions.php
sed -i "/127.0.0.1/ s/''/'$PASS'/" about/instructions.php

# Setup bWAPP
cd /var/www/html/bwapp/bWAPP
sed -i '/db_server/ s/localhost/127.0.0.1/' admin/settings.php
sed -i '/db_pass/ s/bug/'$PASS'/' admin/settings.php

# XVWA
mysql -u root -p$PASS -e "CREATE DATABASE IF NOT EXISTS xvwa"



# php-fpm is required to ensure that php works
mkdir /run/php-fpm
php-fpm &
# Run apache
sed -i 's;SetHandler .*;SetHandler proxy:fcgi://127.0.0.1:8000;' /etc/httpd/conf.d/php.conf
/usr/sbin/httpd &
mysqld_safe &


echo "Mysql password for root is set to :: $(cat  ~/mysql_password.txt)"

## This is useful if something goes wrong.
while (( 1 ))
do
    sleep 3600
done


