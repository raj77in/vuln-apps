#!/bin/bash - 
#===============================================================================
#
#          FILE: build.sh
# 
#         USAGE: ./build.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@mobileum.com
#  ORGANIZATION: Individual
#       CREATED: 06/07/2019 22:32
# Last modified: Fri Jun 07, 2019  10:32PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
sudo docker build -t raj77in/vuln-apps .

