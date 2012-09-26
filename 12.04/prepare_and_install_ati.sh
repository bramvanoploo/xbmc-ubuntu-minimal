#!/bin/sh

VIDEO_DRIVER="fglrx"
VIDEO_MANUFACTURER="ATI"

echo ""
echo "-----------"
echo ""
echo "Please enter your password to start Ubuntu preparation and XBMC installation."
echo "Your computer will restart automatically once the process has been completed."

## Fix locale bug
sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'

echo "-----"
echo "Locale environment bug successfully fixed"
echo "Adding Wsnipex xbmc-xvba-testing PPA..."

## Add XBMCbuntu testing ppa to sources.list and reload repositories
sudo sh -c 'echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list'
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list'

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null
sudo apt-get update > /dev/null
sudo apt-get -y dist-upgrade > /dev/null

echo "Wsnipex xbmc-xvba-testing PPA successfully added"

## Fix uxlaunch requirement
sudo mkdir -p /var/lib/polkit-1/localauthority/50-local.d
sudo mkdir /etc/uxlaunch
sudo touch /etc/uxlaunch/uxlaunch

echo "Uxlaunch requirement fixed"
echo "Installing lightdm (this will take a while)..."

## Install lightdm
sudo apt-get -y install lightdm > /dev/null

echo "Lightdm successfully installed"
echo "Installing $VIDEO_MANUFACTURER video drivers..."

## Install nvidia video drivers
sudo apt-get -y install $VIDEO_DRIVER > /dev/null

echo "$VIDEO_MANUFACTURER video drivers successfully installed"
echo "Installing XBMC-live..."

sudo apt-get -y install xbmc-live > /dev/null

echo "XBMC-live successfully installed"
echo "Rebooting..."

## Reboot
sudo reboot now > /dev/null
