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
#        AUTHOR: Amit Agarwal (aka),
#  ORGANIZATION: Individual
#       CREATED: 08/01/2025 10:57:13 PM
#      REVISION:  ---
#===============================================================================

#!/bin/bash

# Author: Amit Agarwal aka
# Updated: 2025-08-01

set -e

# Set MySQL root password
export PASS="${MYSQL_PASS:-PPAAssWW00RRdd}"
echo "$PASS" > ~/mysql_password.txt
echo "[+] Using MySQL root password: $PASS"

# Configure PHP limits
PHP_INI="/etc/php.ini"
sed -i "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" "$PHP_INI"
sed -i "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" "$PHP_INI"
sed -i "s/^;*allow_url_include.*/allow_url_include = On/" "$PHP_INI"

# Create MySQL user
MYSQL_PASS=$PASS /root/bin/create_mysql_admin_user.sh

# Update legacy `mysql_` to `mysqli_`
cd /var/www/html
echo "[*] Patching legacy mysql_ functions..."
grep -rIl 'mysql_' . | while read -r file; do
    echo "Changing in $file"
    sed -i 's/mysql_/mysqli_/g' "$file"
done

# Fix permissions for DVWA
chmod 777 \
  /var/www/html/DVWA//hackable/uploads \
  /var/www/html/DVWA/config
cd /var/www/html/DVWA
cp config/config.inc.php.dist config/config.inc.php
# chown -R apache:apache /var/www/html/

# Install DVWA config
/root/bin/dvwa-install.sh

# Start DVNA if present
if id dvna &>/dev/null && [[ -f /home/dvna/dvna.js ]]; then
  su - dvna -c "node dvna.js" &
fi

# Start WebGoat and WebWolf
echo "[*] Starting WebGoat and WebWolf..."
cd /root/webgoat
nohup java -Djava.security.egd=file:/dev/urandom -jar webgoat.jar --server.address=0.0.0.0 > /root/webgoat.log 2>&1 &

# Patch OWASP Bricks
echo "[*] Patching OWASP Bricks mysqli_query usage..."
BRICKS_DIR="/var/www/html/owasp-bricks/bricks"
sed -i 's/mysqli_query(/mysqli_query($con,/' "$BRICKS_DIR/config/setup.php"
grep -rIl 'mysqli_query(' "$BRICKS_DIR" | while read -r file; do
  sed -i 's/mysqli_query(/mysqli_query($con,/' "$file"
done

# Patch Mutillidae credentials
sed -i "s/DB_PASSWORD',.*/DB_PASSWORD', '$PASS');/" /var/www/html/mutillidae/includes/database-config.inc

# Configure DVWS
DVWS_DIR="/var/www/html/dvws"
sed -i 's/localhost/127.0.0.1/g' "$DVWS_DIR/instructions.php"
sed -i "s/''/'$PASS'/" "$DVWS_DIR/instructions.php"
sed -i 's/localhost/127.0.0.1/g' "$DVWS_DIR/about/instructions.php"
sed -i "s/''/'$PASS'/" "$DVWS_DIR/about/instructions.php"

# Configure bWAPP
BWAPP_DIR="/var/www/html/bwapp/bWAPP"
sed -i 's/localhost/127.0.0.1/' "$BWAPP_DIR/admin/settings.php"
sed -i "s/'bug'/'$PASS'/" "$BWAPP_DIR/admin/settings.php"

# Create XVWA database
echo "[*] Creating database for XVWA..."
mysql -u root -p"$PASS" -e "CREATE DATABASE IF NOT EXISTS xvwa;"

# Start PHP-FPM
echo "[*] Starting php-fpm..."
mkdir -p /run/php-fpm
php-fpm &

# Ensure Apache is using proxy:fcgi
sed -i 's;SetHandler .*;SetHandler "proxy:fcgi://127.0.0.1:8000";' /etc/httpd/conf.d/php.conf

# Start Apache
echo "[*] Starting Apache..."
/usr/sbin/httpd &

# Start MySQL
echo "[*] Starting MariaDB..."
mysqld_safe &

echo "[*] Setup complete. MySQL root password is: $(cat ~/mysql_password.txt)"

# Keep container alive
tail -f /dev/null

