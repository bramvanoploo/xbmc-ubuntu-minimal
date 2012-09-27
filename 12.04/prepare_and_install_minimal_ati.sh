#!/bin/sh

VIDEO_DRIVER="fglrx"
VIDEO_MANUFACTURER="ATI"

SOURCES_FILE="/etc/apt/sources.list"
SOURCES_BACKUP_FILE="/etc/apt/sources.list.bak"
ENVIRONMENT_FILE="/etc/environment" 
ENVIRONMENT_BACKUP_FILE="/etc/environment.bak"
INIT_FILE="/etc/init.d/xbmc" 

echo ""
echo "-----------"
echo ">> $(tput setaf 3)Please enter your password to start Ubuntu preparation and XBMC installation and be pation while the installation is in progress.$(tput sgr0)"
echo ">> $(tput setaf 3)The installation of some packages may take a while depending on your internet connection speed.$(tput sgr0)"
echo ""

if [ -f $ENVIRONMENT_BACKUP_FILE ];
then
	sudo rm $ENVIRONMENT_FILE > /dev/null
	sudo cp $ENVIRONMENT_BACKUP_FILE $ENVIRONMENT_FILE > /dev/null
else
	sudo cp $ENVIRONMENT_FILE $ENVIRONMENT_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'

echo "$(tput setaf 3)-----"
echo "$(tput setaf 2)$(tput bold)* Locale environment bug successfully fixed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Adding Wsnipex xbmc-xvba-testing PPA...$(tput sgr0)"

if [ -f $SOURCES_BACKUP_FILE ];
then
	echo "$(tput setaf 3)- Restoring original sources.list file$(tput sgr0)"
	sudo rm $SOURCES_FILE > /dev/null
	sudo cp $SOURCES_BACKUP_FILE $SOURCES_FILE > /dev/null
else
	echo "$(tput setaf 3)- Backing up original sources.list file$(tput sgr0)"
	sudo cp $SOURCES_FILE $SOURCES_BACKUP_FILE > /dev/null
fi

sudo sh -c 'echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list' > /dev/null

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null
sudo apt-get update > /dev/null
sudo apt-get -y dist-upgrade > /dev/null

echo "$(tput setaf 2)$(tput bold)* Wsnipex xbmc-xvba-testing PPA successfully added$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing xinit...$(tput sgr0)"

sudo apt-get -y install xinit > /dev/null

echo "$(tput setaf 2)$(tput bold)* Xinit successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing XBMC...$(tput sgr0)"

sudo apt-get -y install xbmc > /dev/null

echo "$(tput setaf 2)$(tput bold)* XBMC successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Installing $VIDEO_MANUFACTURER video drivers...$(tput sgr0)"

## Install nvidia video drivers
sudo apt-get -y install $VIDEO_DRIVER > /dev/null

echo "$(tput setaf 2)$(tput bold)* $VIDEO_MANUFACTURER video drivers successfully installed$(tput sgr0)"
echo ""
echo "$(tput setaf 3)$(tput bold)Downloading and applying xbmc init.d script$(tput sgr0)"

mkdir ~/temp && cd ~/temp > /dev/null
wget https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/xbmc_init_script > /dev/null

if [ -f $INIT_FILE ];
then
	sudo rm $INIT_FILE > /dev/null
fi

sudo mv ./xbmc_init_script $INIT_FILE > /dev/null
sudo rm -r ~/temp > /dev/null
sudo chmod a+x /etc/init.d/xbmc > /dev/null
sudo update-rc.d xbmc defaults > /dev/null

echo "$(tput setaf 2)$(tput bold)* init.d script succesfully downloaded and applied$(tput sgr0)"
echo ""
#echo "Reconfiguring X-server..."

#sudo dpkg-reconfigure x11-common

# echo "* X-server successfully reconfigured"
echo "$(tput setaf 6)$(tput bold)Rebooting system...$(tput sgr0)"

## Reboot
sudo reboot now > /dev/null