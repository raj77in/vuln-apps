#!/bin/bash

nohup /usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ $RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-PPAAssWW00RRdd}

echo "=> Creating MySQL admin user with ${PASS} password"

mysql -uroot mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot mysql -e "FLUSH PRIVILEGES;"
printf "y\nG8yHPp-i9jwMbKqhutqUcWM_E5W7XK9O\nn\n\n\n\n\n\n\n\n\n"|sudo mysql_secure_installation 2>&1


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

mysqladmin -uroot shutdown
sed -i 's/static public $mMySQLDatabasePassword =.*/static public $mMySQLDatabasePassword = \"'$PASS'\";/g' /var/www/html/mutillidae/classes/MySQLHandler.php
sed -i 's/p@ssw0rd/'$PASS'/g' /var/www/html/dvwa/DVWA-master/config/config.inc.php

sed -i 's/.dbpass = .*password/$dbpass = "'"$PASS"'";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php
sed -i 's/.host = .*/$host = "127.0.0.1";/'  /var/www/html/owasp-bricks/bricks/LocalSettings.php
