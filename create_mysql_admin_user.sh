#!/bin/bash


export PASS=${MYSQL_PASS:-PPAAssWW00RRdd}
killall -9 mysqld_safe
mysqld_safe &
## Without sleep the script will fail.
sleep 3
printf "\ny\ny\n$PASS\n$PASS\ny\n\n\n\n\n\n\n\n\n"|mysql_secure_installation 2>&1


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

#mysqladmin -uroot shutdown
sed -i 's/static public $mMySQLDatabasePassword =.*/static public $mMySQLDatabasePassword = \"'$PASS'\";/g' /var/www/html/mutillidae/classes/MySQLHandler.php

sed -i 's/.dbpass = .*password/$dbpass = "'"$PASS"'";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php
sed -i 's/.host = .*/$host = "127.0.0.1";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php

mysql -u root -p$PASS -e "create database inject;"
