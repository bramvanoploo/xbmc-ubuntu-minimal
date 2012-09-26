#!/bin/sh

echo "Please enter your password to start Ubuntu preparation and XBMC installation."
echo "Your computer will restart automatically once the process has been completed."
sudo -s

## Fix locale bug
echo "LC_MESSAGES=\"C\"" >> /etc/environment
echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment

echo "-----"
echo "Locale environment bug successfully fixed"
echo "Adding Wsnipex xbmc-xvba-testing PPA..."

## Add XBMCbuntu testing ppa to sources.list and reload repositories
echo "" >> /etc/apt/sources.list
echo "## XBMCbuntu testing PPA" >> /etc/apt/sources.list
echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list

apt-key -y adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null
apt-get update && apt-get -y dist-upgrade > /dev/null

echo "Wsnipex xbmc-xvba-testing PPA successfully added"

## Fix uxlaunch requirement
mkdir -p /var/lib/polkit-1/localauthority/50-local.d/
mkdir /etc/uxlaunch/
touch /etc/uxlaunch/uxlaunch

echo "Uxlaunch requirement fixed"
echo "Installing lightdm (this will take a while)..."

## Install lightdm
apt-get -y install lightdm > /dev/null

echo "Lightdm successfully installed"
echo "Installing nvidia video drivers..."

## Install nvidia video drivers
apt-get -y install nvidia-current > /dev/null

echo "Nvidia video drivers successfully installed"
echo "Rebooting..."

## Reboot
reboot now > /dev/null
