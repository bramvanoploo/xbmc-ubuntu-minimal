#!/bin/sh

VIDEO_DRIVER="nvidia-current"
VIDEO_MANUFACTURER="NVIDIA"
SOURCES_FILE="/etc/apt/sources.list"
SOURCES_BACKUP_FILE="/etc/apt/sources.list.orig"
ENVIRONMENT_FILE="/etc/environment" 
ENVIRONMENT_BACKUP_FILE="/etc/environment.bak" 

echo ""
echo "-----------"
echo ">> Please enter your password to start Ubuntu preparation and XBMC installation and be pation while the installation is in progress."
echo ">> The installation of some packages may take a while depending on your internet connection speed."
echo ""
echo "Your computer will restart automatically once the process has been completed!"

if [ -f $ENVIRONMENT_BACKUP_FILE ];
then
	sudo rm $ENVIRONMENT_FILE > /dev/null
	sudo cp $ENVIRONMENT_BACKUP_FILE $ENVIRONMENT_FILE > /dev/null
else
	sudo cp $ENVIRONMENT_FILE $ENVIRONMENT_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'

echo "-----"
echo "* Locale environment bug successfully fixed"
echo "Adding Wsnipex xbmc-xvba-testing PPA..."

if [ -f $SOURCES_BACKUP_FILE ];
then
	echo "- Restoring original sources.list file"
	sudo rm $SOURCES_FILE > /dev/null
	sudo cp $SOURCES_BACKUP_FILE $SOURCES_FILE > /dev/null
else
	echo "- Backing up original sources.list file"
	sudo cp $SOURCES_FILE $SOURCES_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null
sudo apt-get update > /dev/null
sudo apt-get -y dist-upgrade > /dev/null

echo "* Wsnipex xbmc-xvba-testing PPA successfully added"
echo "Installing xinit..."

sudo apt-get -y install xinit > /dev/null

echo "* Xinit successfully installed"
echo "Installing XBMC..."

sudo apt-get -y install xbmc > /dev/null

echo "* XBMC successfully installed"
echo "Installing $VIDEO_MANUFACTURER video drivers..."

## Install nvidia video drivers
sudo apt-get -y install $VIDEO_DRIVER > /dev/null

echo "* $VIDEO_MANUFACTURER video drivers successfully installed"
echo "Downloading and applying xbmc init.d script"

mkdir ~/temp && cd ~/temp > /dev/null
wget https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/xbmc_init_script > /dev/null
sudo mv ./xbmc_init_script /etc/init.d/xbmc > /dev/null
sudo rm -r ~/temp > /dev/null
sudo chmod a+x /etc/init.d/xbmc > /dev/null
sudo update-rc.d xbmc defaults > /dev/null

echo "* init.d script succesfully downloaded and applied"
#echo "Reconfiguring X-server..."

#sudo dpkg-reconfigure x11-common

# echo "* X-server successfully reconfigured"
echo "Rebooting system..."

## Reboot
sudo reboot now > /dev/null
