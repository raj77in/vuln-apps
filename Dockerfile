FROM fedora

# Setup mysql server

RUN dnf install -y mysql-server; dnf clean all
ADD my.cnf /etc/mysql/conf.d/my.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /root/bin/create_mysql_admin_user.sh


#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
# VOLUME  ["/etc/mysql", "/var/lib/mysql" ]


# install sshd and apache 
RUN dnf clean all; dnf install -y  httpd php openssh-server unzip ; dnf clean all;
RUN useradd -c "Vuln User" -m guest
RUN echo "guest:guest"|chpasswd
RUN echo "root:password" |chpasswd


# Add DVWA
#
RUN mkdir /var/www/html/dvwa
ADD https://github.com/ethicalhack3r/DVWA/archive/master.tar.gz /var/www/html/dvwa/

RUN dnf install -y wget ; dnf clean all;

# Deploy Mutillidae
RUN \
	mkdir /root/mutillidae && \
	cd /root/mutillidae && \
  wget -O /root/mutillidae/mutillidae.zip http://sourceforge.net/projects/mutillidae/files/latest/download && \
  unzip /root/mutillidae/mutillidae.zip && \
  cp -r /root/mutillidae/mutillidae /var/www/html/  && \
  rm -rf /root/mutillidae

RUN \
  sed -i 's/static public \$mMySQLDatabaseUsername =.*/static public \$mMySQLDatabaseUsername = "admin";/g' /var/www/html/mutillidae/classes/MySQLHandler.php && \
  echo "sed -i 's/static public \$mMySQLDatabasePassword =.*/static public \$mMySQLDatabasePassword = \\\"'\$PASS'\\\";/g' /var/www/html/mutillidae/classes/MySQLHandler.php" >> //root/bin/create_mysql_admin_user.sh


# Add webgoat
RUN dnf install -y  java-1.8.0-openjdk; dnf clean all
RUN mkdir /root/webgoat
RUN cd /root/webgoat; curl --header 'Host: github.com' --header 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.5' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Cookie: logged_in=yes; _ga=GA1.2.682912172.1471179804; _octo=GH1.1.694985160.1471179804; user_session=KMZl4SQVRl6ox7GSv_8rirPQbkHGxmojaaIW5AjyXiGzNyAl; __Host-user_session_same_site=KMZl4SQVRl6ox7GSv_8rirPQbkHGxmojaaIW5AjyXiGzNyAl; dotcom_user=raj77in; _gh_sess=eyJzZXNzaW9uX2lkIjoiMWIxYWE3MmU1MWE1NGM5OTJlZWE1ODIyMWJkZWM1M2YiLCJzcHlfcmVwbyI6IldlYkdvYXQvV2ViR29hdCIsInNweV9yZXBvX2F0IjoxNDk0MDA2OTQ3fQ%3D%3D--b59a2f5ad8d1f2fea98954c69dc381bd8b3cb1de; _gat=1; tz=UTC' 'https://github.com/WebGoat/WebGoat/releases/download/7.1/webgoat-container-7.1-exec.jar' -O -J -L

# Run DVNA
##   <aka> ## ENV VERSION master
##   <aka> ## RUN dnf install -y tar npm ; dnf clean all;
##   <aka> ## WORKDIR /DVNA-$VERSION/
##   <aka> ## RUN useradd -d /DVNA-$VERSION/ dvna \
##   <aka> ## 	&& chown dvna: /DVNA-$VERSION/
##   <aka> ## USER dvna
##   <aka> ## RUN curl -sSL 'https://github.com/raj77in/dvna-1/archive/master.tar.gz' \
##   <aka> ## 	| tar -vxz -C /DVNA-$VERSION/ \
##   <aka> ## 	&& cd /DVNA-$VERSION/dvna-1-master \
##   <aka> ## 	&& npm set progress=false \
##   <aka> ## 	&& npm install



# Add commix
RUN mkdir /var/www/html/commix
ADD https://github.com/commixproject/commix/archive/master.tar.gz /var/www/html/commix

ADD start.sh /root/bin
# Add index file
ADD index.html /var/www/html

RUN chmod +x /root/bin/*.sh

# Fix mariadb issue
RUN dnf install hostname -y; dnf clean all;
RUN rm -rf /etc/my.cnf.d/auth_gssapi.cnf ; rm -rf /var/lib/mysql; echo -e 'innodb_buffer_pool_size=16M\ninnodb_additional_mem_pool_size=500K\ninnodb_log_buffer_size=500K\ninnodb_thread_concurrency=2' >>/etc/my.cnf.d/mariadb-server.cnf
RUN chown -R mysql /var/lib/mysql/ ;  mysql_install_db --user=mysql --ldata=/var/lib/mysql ; 

# Extract the tar files:
##   <aka> ## RUN dnf install -y tar python2 ; dnf clean all;
##   <aka> ## RUN cd /var/www/html/dvwa/; tar xvf master.tar.gz ; cd DVWA-master; cp config/config.inc.php.dist config/config.inc.php
##   <aka> ## RUN cd /var/www/html/commix/; tar xvf master.tar.gz


EXPOSE 22 80 8080 3000 3306

CMD "/root/bin/start.sh"
