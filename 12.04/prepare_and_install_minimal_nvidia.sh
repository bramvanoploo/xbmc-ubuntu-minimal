#!/bin/sh

VIDEO_DRIVER="nvidia-current"
VIDEO_MANUFACTURER="NVIDIA"

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
echo "Installing xinit..."

sudo apt-get install xinit > /dev/null

echo "Xinit successfully installed"
echo "Installing XBMC..."

sudo apt-get -y install xbmc > /dev/null

echo "XBMC successfully installed"
echo "Installing $VIDEO_MANUFACTURER video drivers..."

## Install nvidia video drivers
sudo apt-get -y install $VIDEO_DRIVER > /dev/null

echo "$VIDEO_MANUFACTURER video drivers successfully installed"
echo "Downloading and applying xbmc init.d script"

mkdir ~/temp && cd ~/temp > /dev/null
wget https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/xbmc_init_script > /dev/null
sudo mv ./xbmc_init_script /etc/init.d/xbmc > /dev/null
sudo rm -r ~/temp > /dev/null
sudo chmod a+x /etc/init.d/xbmc > /dev/null
sudo update-rc.d xbmc defaults > /dev/null

echo "init.d script succesfully downloaded and applied"
echo "Rebooting system..."

## Reboot
sudo reboot now > /dev/null
