#!/bin/bash
#
# @author   Bram van Oploo
# @date     2013-02-12
# @version  3.0.0
#

clear

echo "* Preparing ubuntu..."
sudo apt-get -y install software-properties-common python python-flask lm-sensors python-apt tar wget > /dev/null 2>&1

#echo "* Downloading and installing installer requirements..."
#Download and install urwid
#mkdir $HOME/temp > /dev/null 2>&1
##cd $HOME/temp > /dev/null 2>&1
#wget http://excess.org/urwid/urwid-1.1.1.tar.gz > /dev/null 2>&1
#tar -xvzf $HOME/temp/urwid-1.1.1.tar.gz > /dev/null 2>&1
#python $HOME/temp/urwid-1.1.1/setup.py build > /dev/null 2>&1
#sudo python $HOME/temp/urwid-1.1.1/setup.py install > /dev/null 2>&1
#sudo rm $HOME/temp/urwid-1.1.1.tar.gz > /dev/null 2>&1
#sudo rm -R $HOME/temp/urwid-1.1.1 > /dev/null 2>&1

#echo "* Starting installer..."
#sudo python /media/storage_linux/Development/Personal/xbmc-ubuntu-minimal/13.04/XbmcInstaller/install.py

echo "* Starting installer..."
sudo python /media/storage_linux/Development/Personal/xbmc-ubuntu-minimal/13.04/InstallXbmc/server.py
