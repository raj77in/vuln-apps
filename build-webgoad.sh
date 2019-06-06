#!/bin/bash - 
#===============================================================================
#
#          FILE: build-webgoad.sh
# 
#         USAGE: ./build-webgoad.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@mobileum.com
#  ORGANIZATION: Mobileum
#       CREATED: 04/30/2017 22:02
# Last modified: Sun Apr 30, 2017  11:34PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


cd /root

mkdir WebGoat
cd WebGoat

curl --header 'Host: codeload.github.com' --header 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Connection: keep-alive' --header 'Upgrade-Insecure-Requests: 1' 'https://codeload.github.com/WebGoat/WebGoat/tar.gz/develop' -L -o webgoat.tar.gz

tar xvf webgoat.tar.gz
cd WebGoat-develop/
mvn clean install

