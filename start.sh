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
# Last modified: Sat May 06, 2017  01:56AM
#      REVISION:  ---
#===============================================================================



# Run mysqld
mysqld_safe &

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /root/bin/create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi


# Run DVNA
su - dvna -c node dvna.js &

# Run WebGoat
cd /root/webgoat
java -Djava.security.egd=file:/dev/urandom -jar  webgoat-container-7.1-exec.jar &



# Run apache
/usr/sbin/apachectl -D FOREGROUND
