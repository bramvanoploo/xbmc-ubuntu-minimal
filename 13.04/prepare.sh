#!/bin/bash
#
# @author   Bram van Oploo
# @date     2013-02-12
# @version  3.0.0
#

sudo apt-get -y install dialog software-properties-common python python-apt > /dev/null 2>&1
mkdir /home/xbmc/temp && cd /home/xbmc/temp
wget https://raw.github.com/Bram77/xbmc-ubuntu-minimal/master/13.04/XbmcInstaller.tar.gz
tar -xvzf ./XbmcInstaller.tar.gz
sudo python ./XbmcInstaller/install.py $1
