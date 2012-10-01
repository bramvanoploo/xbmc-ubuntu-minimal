#!/bin/bash

USER="xbmc"
THIS_FILE=$0
VIDEO_MANUFACTURER=$1
VIDEO_DRIVER=""
VIDEO_MANUFACTURER_NAME=""
HOME_DIRECTORY="/home/$USER/"
TEMP_DIRECTORY=$HOME_DIRECTORY"temp/"
SOURCES_FILE="/etc/apt/sources.list"
SOURCES_BACKUP_FILE="/etc/apt/sources.list.bak"
ENVIRONMENT_FILE="/etc/environment" 
ENVIRONMENT_BACKUP_FILE="/etc/environment.bak"
INIT_FILE="/etc/init.d/$USER"
XBMC_ADDONS_DIR=$HOME_DIRECTORY".xbmc/addons/"
XBMC_USERDATA_DIR=$HOME_DIRECTORY".xbmc/userdata/"
XBMC_ADVANCEDSETTINGS_FILE=$XBMC_USERDATA_DIR"advancedsettings.xml"
XBMC_ADVANCEDSETTINGS_BACKUP_FILE=$XBMC_USERDATA_DIR"advancedsettings.xml.bak"
XWRAPPER_BACKUP_FILE="/etc/X11/Xwrapper.config.bak"
XWRAPPER_FILE="/etc/X11/Xwrapper.config"
LOG_FILE=$HOME_DIRECTORY"xbmc_installation.log"
LOG_TEXT="\n"
DIALOG_WIDTH=80

## ------ START functions ---------

function log()
{
	LOG_TEXT="$LOG_TEXT$@\n"
	dialog --infobox "$LOG_TEXT" 34 $DIALOG_WIDTH
}

function showDialog()
{
	dialog --title "XBMC installation script" \
		--msgbox "\n$@" 12 $DIALOG_WIDTH
}

function showErrorDialog()
{
	dialog --title "ERROR: XBMC installation script" \
		--msgbox "\n$@" 8 $DIALOG_WIDTH
}

function installDependencies()
{
	sudo apt-get -y -qq install dialog software-properties-common
}

function hasRequiredParams()
{
	if [ $VIDEO_MANUFACTURER == "ati" ];
	then
		VIDEO_DRIVER="fglrx"
		VIDEO_MANUFACTURER_NAME="ATI"
	elif [ $VIDEO_MANUFACTURER == "nvidia" ];
	then
		VIDEO_DRIVER="nvidia-current"
		VIDEO_MANUFACTURER_NAME="NVIDIA"
	elif [ $VIDEO_MANUFACTURER == "intel" ];
	then
		VIDEO_DRIVER="i965-va-driver"
		VIDEO_MANUFACTURER_NAME="INTEL"
	else
		MESSAGE="Please provide the videocard manufacturer parameter (ati/nvidia/intel)"
		showErrorDialog "$MESSAGE"
		clear
		exit
	fi
}

function fixLocaleBug()
{
	if [ -f $ENVIRONMENT_BACKUP_FILE ];
	then
		sudo rm $ENVIRONMENT_FILE > /dev/null
		sudo cp $ENVIRONMENT_BACKUP_FILE $ENVIRONMENT_FILE > /dev/null
	else
		sudo cp $ENVIRONMENT_FILE $ENVIRONMENT_BACKUP_FILE > /dev/null
	fi

	sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
	sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'
}

function applyXbmcNiceLevelPermissions()
{
	if [ ! -f /etc/security/limits.conf ];
	then
		sudo touch /etc/security/limits.conf > /dev/null
	fi

	sudo sh -c 'echo "xbmc             -       nice            -1" >> /etc/security/limits.conf' > /dev/null
}

function addUserToRequiredGroups()
{
	sudo adduser $USER video > /dev/null 2>&1
	sudo adduser $USER audio > /dev/null 2>&1
	sudo adduser $USER users > /dev/null 2>&1
}

function addXbmcPpa()
{
	sudo add-apt-repository -y ppa:wsnipex/xbmc-xvba > /dev/null 2>&1
}

function distUpgrade()
{
	sudo apt-get -qq update
	sudo apt-get -y -qq dist-upgrade > /dev/null 2>&1
}

function installXinit()
{
	sudo apt-get -y -qq install xinit
}

function installPowerManagement()
{
	sudo apt-get -y -qq install policykit-1 upower udisks acpi-support
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/custom-actions.pkla
	sudo mkdir -p /var/lib/polkit-1/localauthority/50-local.d/
	sudo mv custom-actions.pkla /var/lib/polkit-1/localauthority/50-local.d/
}

function installAudio()
{
	sudo apt-get -y -qq install linux-sound-base alsa-base alsa-utils pulseaudio libasound2
	sudo alsamixer
}

function confirmLircInstallation()
{
	dialog --title "Lirc installation" \
		--yesno "Do you want to install and configure Infra Red remote support?" 7 $DIALOG_WIDTH

	RESPONSE=$?
	case $RESPONSE in
	   0) installLirc;;
	   1) cancelLircInstallation;;
	   255) cancelLircInstallation;;
	esac
}

function installLirc()
{
	sudo apt-get -y -qq install lirc
	log "[x] Lirc successfully installed"
}

function cancelLircInstallation()
{
	log "[ ] Lirc installation skipped"
}

function installXbmc()
{
	sudo apt-get -y -qq install xbmc
}

function confirmEnableDirtyRegionRendering()
{
	dialog --title "Dirty region rendering" \
		--yesno "Do you wish to enable dirty region rendering in XBMC? (this will replace your existing advancedsettings.xml)?" 7 150

	RESPONSE=$?
	case $RESPONSE in
	   0) enableDirtyRegionRendering;;
	   1) log "[ ] XBMC dirty-region-rendering not enabled";;
	   255) log "[ ] XBMC dirty-region-rendering not enabled";;
	esac
}

function enableDirtyRegionRendering()
{
	if [ -f $XBMC_ADVANCEDSETTINGS_BACKUP_FILE ];
	then
		rm $XBMC_ADVANCEDSETTINGS_BACKUP_FILE > /dev/null
	fi

	if [ -f $XBMC_ADVANCEDSETTINGS_FILE ];
	then
		mv $XBMC_ADVANCEDSETTINGS_FILE $XBMC_ADVANCEDSETTINGS_BACKUP_FILE > /dev/null
	fi
	
	mkdir -p $TEMP_DIRECTORY > /dev/null
	cd $TEMP_DIRECTORY > /dev/null
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/dirty_region_rendering.xml
	mkdir -p $XBMC_USERDATA_DIR > /dev/null
	mv dirty_region_rendering.xml $XBMC_ADVANCEDSETTINGS_FILE > /dev/null

	log "[x] XBMC dirty-region-rendering enabled"
}

function installXbmcAddonRepositoriesInstaller()
{
	mkdir -p $TEMP_DIRECTORY > /dev/null
	cd $TEMP_DIRECTORY > /dev/null
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/addons/plugin.program.repo.installer-1.0.5.tar.gz

	if [ ! -d $XBMC_ADDONS_DIR ];
	then
		mkdir -p $XBMC_ADDONS_DIR > /dev/null
	fi

	tar -xvzf ./plugin.program.repo.installer-1.0.5.tar.gz -C $XBMC_ADDONS_DIR > /dev/null 2>&1
}

function installVideoDriver()
{
	sudo apt-get -y -qq install $VIDEO_DRIVER

	if [ $VIDEO_MANUFACTURER == "ati" ];
	then
		sudo aticonfig --initial -f > /dev/null
		sudo aticonfig --sync-vsync=on > /dev/null
		sudo aticonfig --set-pcs-u32=MCIL,HWUVD_H264Level51Support,1 > /dev/null
		
		dialog --title "Disable underscan" \
			--yesno "Do you want to disable underscan (removes black borders)? Do this only if you're sure you need it!" 7 $DIALOG_WIDTH

		RESPONSE=$?
		case $RESPONSE in
		   0) disbaleAtiUnderscan;;
		   1) enableAtiUnderscan;;
		   255) log "* ATI underscan configuration skipped";;
		esac
	fi
}

function disbaleAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0 > /dev/null
	log "[ ] Underscan successfully disabled"
}

function enableAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,1 > /dev/null
	log "[x] Underscan successfully enabled"
}

function installXbmcAutorunScript()
{
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/xbmc_init_script > /dev/null

	if [ -f $INIT_FILE ];
	then
		sudo rm $INIT_FILE > /dev/null
	fi

	sudo mv ./xbmc_init_script $INIT_FILE > /dev/null
	sudo chmod a+x /etc/init.d/xbmc > /dev/null
	sudo update-rc.d xbmc defaults > /dev/null
}

function installXbmcBootScreen()
{
	sudo apt-get -y -qq install plymouth-label v86d
	
	cd $TEMP_DIRECTORY
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/plymouth-theme-xbmc-logo.deb
	sudo dpkg -i plymouth-theme-xbmc-logo.deb > /dev/null

	if [ -f /etc/initramfs-tools/conf.d/splash ];
	then
		sudo rm /etc/initramfs-tools/conf.d/splash > /dev/null
	fi

	sudo touch /etc/initramfs-tools/conf.d/splash > /dev/null
	sudo sh -c 'echo "FRAMEBUFFER=y" >> /etc/initramfs-tools/conf.d/splash' > /dev/null
	sudo update-grub > /dev/null 2>&1
	sudo update-initramfs -u > /dev/null 2>&1
}

function reconfigureXServer()
{
	if [ ! -f $XWRAPPER_BACKUP_FILE ];
	then
		sudo mv $XWRAPPER_FILE $XWRAPPER_BACKUP_FILE > /dev/null
	fi

	if [ -f $XWRAPPER_FILE ];
	then
		sudo rm $XWRAPPER_FILE > /dev/null
	fi

	sudo touch $XWRAPPER_FILE > /dev/null
	sudo sh -c 'echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config' > /dev/null
	#sudo dpkg-reconfigure x11-common
}

function cleanUp()
{
	sudo apt-get -y autoclean > /dev/null
	sudo apt-get -y autoremove > /dev/null
	sudo rm -r $TEMP_DIRECTORY > /dev/null
	rm $HOME_DIRECTORY$THIS_FILE
}

function rebootMachine()
{
	dialog --title "Installation complete" \
		--yesno "Do you want to reboot now?" 7 $DIALOG_WIDTH

	RESPONSE=$?
	case $RESPONSE in
	   0) sudo reboot now > /dev/null;;
	   1) quit;;
	   255) quit;;
	esac
}

function quit()
{
	#clear
	exit
}

control_c()
{
  quit
}

## ------- END functions -------

clear

showDialog "Welcome to the XBMC minimal installation script.\n\nSome parts may take a while to install depending on your internet connection speed. Please be patient or exit with CTRL+C!"

trap control_c SIGINT

if [ -f $LOG_FILE ];
then
	rm $LOG_FILE
	touch $LOG_FILE
fi

log "-- Installing installation dependencies..."
installDependencies

hasRequiredParams $VIDEO_MANUFACTURER

fixLocaleBug
log "[x] Locale environment bug fixed"

applyXbmcNiceLevelPermissions
log "[x] Allowed XBMC to prioritize threads"

addUserToRequiredGroups
log "[x] XBMC user added to required groups"

log "-- Adding Wsnipex xbmc-xvba PPA..."
addXbmcPpa
distUpgrade
log "[x] Wsnipex xbmc-xvba PPA successfully added"

log "-- Installing xinit..."
installXinit
log "[x] Xinit successfully installed"

log "-- Installing power management packages..."
installPowerManagement
log "[x] Power management packages successfully installed"

log "-- Installing audio packages..."
log "!! Please make sure no used channels are muted !!"
installAudio
log "[x] Audio packages successfully installed"

confirmLircInstallation

log "-- Installing XBMC..."
installXbmc
log "[x] XBMC successfully installed"

confirmEnableDirtyRegionRendering

log "-- Installing Addon repositories installer plugin..."
installXbmcAddonRepositoriesInstaller
log "[x] Addon repositories installer plugin successfully installed"

log "Installing $VIDEO_MANUFACTURER_NAME video drivers..."
installVideoDriver
log "[x] $VIDEO_MANUFACTURER_NAME video drivers successfully installed"

log "-- Installing XBMC autorun script..."
installXbmcAutoRunScript
log "[x] XBMC autorun script succesfully installed"

log "-- Installing XBMC boot screen..."
installXbmcBootScreen
log "[x] XBMC boot screen successfully installed"

log "-- Reconfiguring X-server..."
reconfigureXServer
log "[x] X-server successfully reconfigured"

log "-- Cleaning up..."
cleanUp

log "-- Rebooting system..."
rebootMachine
