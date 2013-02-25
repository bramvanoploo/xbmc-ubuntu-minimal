#!/bin/sh
#
# @author   Bram van Oploo
# @date     2013-02-12
# @version  3.0.0
#

clear

echo "* Preparing ubuntu..."
sudo apt-get -y install python-software-properties software-properties-common ppa-purge python python-flask python-apt python-beautifulsoup unzip tar > /dev/null 2>&1

echo "* Downloading and installing Software package"
cd ~
wget https://github.com/Bram77/xbmc-ubuntu-minimal/raw/13.04_3.0.0/13.04/xbmcsystemtools.tar.gz
# extract
# apply init.d
# run service
# show message