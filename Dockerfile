FROM fedora:latest

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_UPLOAD_MAX_FILESIZE=10M \
    PHP_POST_MAX_SIZE=10M

# Upgrade base system and install essentials
RUN dnf -y upgrade --refresh && \
    dnf install -y \
        mariadb-server httpd php openssh-server unzip wget \
        hostname git \
        php-common php-pecl-apcu php-cli php-pear php-pdo \
        php-mysqlnd php-pgsql php-pecl-mongodb \
        php-pecl-memcache php-pecl-memcached php-gd \
        php-mbstring php-mcrypt php-xml php-fpm iputils iproute \
        procps-ng java-latest-openjdk \
    --skip-broken --setopt=install_weak_deps=False && \
    dnf clean all


# Add MySQL config and reset default DB
ADD my.cnf /etc/my.cnf.d/my.cnf
RUN rm -rf /var/lib/mysql/*

# Add utility scripts
RUN mkdir -p /root/bin
ADD create_mysql_admin_user.sh /root/bin/create_mysql_admin_user.sh
ADD dvwa-install.sh /root/bin/dvwa-install.sh

RUN chmod +x /root/bin/*.sh

# Add default Apache user
RUN useradd -c "Vuln User" -m guest && \
    echo "guest:guest" | chpasswd && \
    echo "root:password" | chpasswd

# DVWA
RUN git clone https://github.com/digininja/DVWA.git /var/www/html/DVWA

# Mutillidae
RUN wget -O /tmp/mutillidae.zip https://github.com/webpwnized/mutillidae/archive/master.zip && \
    unzip /tmp/mutillidae.zip -d /tmp && \
    mv /tmp/mutillidae-main/src /var/www/html/mutillidae && \
    sed -i 's/static public \$mMySQLDatabaseUsername =.*/static public \$mMySQLDatabaseUsername = "root";/' /var/www/html/mutillidae/classes/MySQLHandler.php && \
    rm -rf /tmp/mutillidae*

# WebGoat + WebWolf
RUN mkdir -p /root/webgoat && cd /root/webgoat && \
    curl -L -o webgoat.jar -O https://github.com/WebGoat/WebGoat/releases/download/v2025.3/webgoat-2025.3.jar

# Commix
RUN mkdir -p /var/www/html/commix && \
    curl -L -o /var/www/html/commix/master.tar.gz https://github.com/commixproject/commix/archive/master.tar.gz && \
    cd /var/www/html/commix && tar xvf master.tar.gz && rm -f master.tar.gz

# Commix Testbed
RUN curl -L -o /var/www/html/commix-testbed.tar.gz https://github.com/commixproject/commix-testbed/archive/master.tar.gz && \
    cd /var/www/html && tar xvf commix-testbed.tar.gz && \
    mv commix-testbed-master commix-testbed && rm -f commix-testbed.tar.gz

# OWASP Bricks
RUN curl -L -o /var/www/html/bricks.zip "https://sourceforge.net/projects/owaspbricks/files/Tuivai%20-%202.2/OWASP%20Bricks%20-%20Tuivai.zip/download" && \
    unzip /var/www/html/bricks.zip -d /var/www/html/owasp-bricks && rm -f /var/www/html/bricks.zip

# bWAPP
RUN mkdir -p /var/www/html/bwapp && \
    curl -L -o /var/www/html/bwapp/bwapp.zip https://sourceforge.net/projects/bwapp/files/bWAPP/bWAPP_latest.zip/download && \
    cd /var/www/html/bwapp && unzip bwapp.zip && \
    chmod -R 777 bWAPP/{passwords,images,documents,logs} && \
    rm -f bwapp.zip

# XVWA
ADD https://raw.githubusercontent.com/s4n7h0/Script-Bucket/master/Bash/xvwa-setup.sh /var/www/html/xvwa-setup.sh
RUN cd /var/www/html && \
    sed -i 's/read uname/uname=root/' xvwa-setup.sh && \
    sed -i "s/read pass/pass=root/" xvwa-setup.sh && \
    sed -i "s;read webroot;webroot=/var/www/html;" xvwa-setup.sh

# Juice Shop
RUN curl -L -o /var/www/html/juice-shop.tgz https://github.com/juice-shop/juice-shop/releases/download/v18.0.0/juice-shop-18.0.0_node20_linux_x64.tgz && \
    cd /var/www/html && tar xvf juice-shop.tgz && mv juice-shop_18.0.0 juice && rm -f juice-shop.tgz

# DVWS
RUN curl -L -o /var/www/html/dvws.tar.gz https://github.com/snoopysecurity/dvws/archive/master.tar.gz && \
    cd /var/www/html && tar xvf dvws.tar.gz && mv dvws-master dvws && rm -f dvws.tar.gz

# MariaDB Fixes
RUN rm -f /etc/my.cnf.d/auth_gssapi.cnf && \
    echo -e 'innodb_buffer_pool_size=16M\ninnodb_log_buffer_size=500K\ninnodb_thread_concurrency=2' >> /etc/my.cnf.d/mariadb-server.cnf && \
    mysql_install_db --user=mysql --ldata=/var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

# Apache + PHP-FPM Fix
RUN sed -i 's/^listen =.*/listen = 127.0.0.1:8000/' /etc/php-fpm.d/www.conf && \
    sed -i 's;.*Handler.*;SetHandler "proxy:fcgi://localhost";' /etc/httpd/conf.d/php.conf

# Custom index
ADD index.html /var/www/html/index.html
ADD start.sh /root/bin/start.sh
RUN chmod +x /root/bin/*.sh


EXPOSE 22 80 8080 3000 3306

CMD ["/root/bin/start.sh"]

