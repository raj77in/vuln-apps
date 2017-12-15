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
# Last modified: Fri Dec 15, 2017  11:55PM
#      REVISION:  ---
#===============================================================================

PASS=${MYSQL_PASS:-PPAAssWW00RRdd}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"
mysql -u root -e "update user set password=PASSWORD('$PASS') where User='root';" mysql


chown apache:apache -R /var/www/html

# Run mysqld
mysqld_safe &

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^allow_url_include.*/allow_url_include = On/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^allow_url_include.*/allow_url_include = On/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php.ini
/root/bin/create_mysql_admin_user.sh

# mysql_* are deprecated...
cd /var/www/html
grep -r -i -l mysql_ *|sort|uniq|while read line
do
    sed -i 's/mysql_/mysqli_/g' $line
done


# Run DVNA
su - dvna -c node dvna.js &

# Run WebGoat
cd /root/webgoat
java -Djava.security.egd=file:/dev/urandom -jar  webgoat-server-8.0.0.M5.jar &


## Fix Bricks..
sed -i 's/mysqli_query(/mysqli_query($con,/' /var/www/html/owasp-bricks/bricks/config/setup.php

cd /var/www/html/owasp-bricks/bricks
grep -r -i -l mysqli_query *|while read line
do
    sed -i 's/mysqli_query(/mysqli_query($con,/' $line
done


# Run apache
/usr/sbin/apachectl -D FOREGROUND

