#!/bin/sh

VIDEO_DRIVER="nvidia-current"
VIDEO_MANUFACTURER="NVIDIA"

rotdash2()
{
p=$1
while [ -d /proc/$p ]
do
echo -n '/^H' ; sleep 0.05
echo -n '-^H' ; sleep 0.05
echo -n '\^H' ; sleep 0.05
echo -n '|^H' ; sleep 0.05
done
}

echo ""
echo "-----------"
echo ""
echo "Please enter your password to start Ubuntu preparation and XBMC installation."
echo "Your computer will restart automatically once the process has been completed."

## Fix locale bug
sudo echo "LC_MESSAGES=\"C\"" >> /etc/environment &
rotdash2 $!
sudo echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment &
rotdash2 $!

echo "-----"
echo "Locale environment bug successfully fixed"
echo "Adding Wsnipex xbmc-xvba-testing PPA..."

## Add XBMCbuntu testing ppa to sources.list and reload repositories
sudo echo "" >> /etc/apt/sources.list &
rotdash2 $!
sudo echo "## XBMCbuntu testing PPA" >> /etc/apt/sources.list &
rotdash2 $!
sudo echo "deb http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list &
rotdash2 $!
sudo echo "deb-src http://ppa.launchpad.net/wsnipex/xbmc-xvba-testing/ubuntu quantal main" >> /etc/apt/sources.list &
rotdash2 $!

sudo apt-key -y adv --keyserver keyserver.ubuntu.com --recv-keys A93CABBC > /dev/null &
rotdash2 $!
sudo apt-get update > /dev/null & 
rotdash2 $!
sudo apt-get -y dist-upgrade > /dev/null &
rotdash2 $!

echo "Wsnipex xbmc-xvba-testing PPA successfully added"

## Fix uxlaunch requirement
sudo mkdir -p /var/lib/polkit-1/localauthority/50-local.d/ &
rotdash2 $!
sudo mkdir /etc/uxlaunch/ &
rotdash2 $!
sudo touch /etc/uxlaunch/uxlaunch &
rotdash2 $!

echo "Uxlaunch requirement fixed"
echo "Installing lightdm (this will take a while)..."

## Install lightdm
sudo apt-get -y install lightdm > /dev/null &
rotdash2 $!

echo "Lightdm successfully installed"
echo "Installing $VIDEO_MANUFACTURER video drivers..."

## Install nvidia video drivers
sudo apt-get -y install $VIDEO_DRIVER > /dev/null &
rotdash2 $!

echo "$VIDEO_MANUFACTURER video drivers successfully installed"
echo "Rebooting..."

## Reboot
sudo reboot now > /dev/null &
rotdash2 $!
