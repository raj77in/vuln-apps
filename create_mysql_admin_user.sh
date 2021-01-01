#!/bin/bash


PASS=${MYSQL_PASS:-PPAAssWW00RRdd}
killall -9 mysqld_safe
printf "\ny\n$PASS\n$PASS\nn\n\n\n\n\n\n\n\n\n"|mysql_secure_installation 2>&1


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
sed -i 's/p@ssw0rd/'$PASS'/g' /var/www/html/dvwa/DVWA-master/config/config.inc.php

sed -i 's/.dbpass = .*password/$dbpass = "'"$PASS"'";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php
sed -i 's/.host = .*/$host = "127.0.0.1";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php
