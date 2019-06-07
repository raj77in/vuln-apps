#!/bin/bash - 
#===============================================================================
#
#          FILE: dvna-install.sh
# 
#         USAGE: ./dvna-install.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@mobileum.com
#  ORGANIZATION: Individual
#       CREATED: 06/07/2019 10:36
# Last modified: Fri Jun 07, 2019  11:03AM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# Run DVNA
VERSION=master
dnf install -y tar npm git python g++ make ; dnf clean all;
cd /DVNA-$VERSION/
useradd -d /DVNA-$VERSION/ dvna
chown dvna: /DVNA-$VERSION/
dvna
#https://github.com/appsecco/dvna
curl -sSL 'https://github.com/raj77in/dvna-1/archive/master.tar.gz' | \
            .ar -vxz -C /DVNA-$VERSION/
cd /DVNA-$VERSION/dvna-1-master
npm set progress=false
npm install
npm install -g nodemon
ln -s /DVNA-master/dvna /app
