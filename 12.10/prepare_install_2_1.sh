#!/bin/bash

USER="xbmc"
THIS_FILE=$0

VIDEO_MANUFACTURER=$1
VIDEO_DRIVER=""
VIDEO_MANUFACTURER_NAME=""

HOME_DIRECTORY="/home/$USER/"
TEMP_DIRECTORY=$HOME_DIRECTORY"temp/"
ENVIRONMENT_FILE="/etc/environment" 
ENVIRONMENT_BACKUP_FILE="/etc/environment.bak"
INIT_FILE="/etc/init.d/xbmc"
XBMC_ADDONS_DIR=$HOME_DIRECTORY".xbmc/addons/"
XBMC_USERDATA_DIR=$HOME_DIRECTORY".xbmc/userdata/"
XBMC_ADVANCEDSETTINGS_FILE=$XBMC_USERDATA_DIR"advancedsettings.xml"
XBMC_ADVANCEDSETTINGS_BACKUP_FILE=$XBMC_USERDATA_DIR"advancedsettings.xml.bak"
XWRAPPER_BACKUP_FILE="/etc/X11/Xwrapper.config.bak"
XWRAPPER_FILE="/etc/X11/Xwrapper.config"

LOG_TEXT="\n"
DIALOG_WIDTH=90
SCRIPT_TITLE="XBMC installation script for Ubuntu 12.10 by Bram van Oploo :: Contact me at bram@sudo-systems.com"

## ------ START functions ---------

function log()
{
	LOG_TEXT="$LOG_TEXT$@\n"
	
	dialog --title "Ubuntu configuration and XBMC installation in progress..." \
		--backtitle "$SCRIPT_TITLE" \
		--infobox "$LOG_TEXT" \
	 	34 $DIALOG_WIDTH
}

function showDialog()
{
	dialog --title "XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 12 $DIALOG_WIDTH
}

function showErrorDialog()
{
	dialog --title "ERROR: XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 8 $DIALOG_WIDTH
}

function installDependencies()
{
    echo "-- Installing installation dependencies..."
    echo ""

	RESULT=$(sudo apt-get -y -qq install dialog software-properties-common > /dev/null)
	
	if [ $RESULT != "" ];
	then
	    echo "FATAL ERROR: Installation dependencies could not be installed '$RESULT'"
	    echo "Installation terminated"
	    exit
	fi
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
    if [ ! -f $ENVIRONMENT_FILE ];
    then
        sudo touch $ENVIRONMENT_FILE
    fi

	if [ -f $ENVIRONMENT_BACKUP_FILE ];
	then
		sudo rm $ENVIRONMENT_FILE > /dev/null
		sudo cp $ENVIRONMENT_BACKUP_FILE $ENVIRONMENT_FILE > /dev/null
	else
		sudo cp $ENVIRONMENT_FILE $ENVIRONMENT_BACKUP_FILE > /dev/null
	fi

	sudo sh -c 'echo "LC_MESSAGES=\"C\"" >> /etc/environment'
	sudo sh -c 'echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/environment'
	
	log "[x] Locale environment bug fixed"
}

function applyXbmcNiceLevelPermissions()
{
	if [ ! -f /etc/security/limits.conf ];
	then
		sudo touch /etc/security/limits.conf > /dev/null
	fi

	sudo sh -c 'echo "xbmc             -       nice            -1" >> /etc/security/limits.conf' > /dev/null
	
	log "[x] Allowed XBMC to prioritize threads"
}

function addUserToRequiredGroups()
{
	sudo adduser $USER video > /dev/null 2>&1
	sudo adduser $USER audio > /dev/null 2>&1
	sudo adduser $USER users > /dev/null 2>&1
	
	log "[x] XBMC user added to required groups"
}

function addXbmcPpa()
{
    log "-- Adding Wsnipex xbmc-xvba PPA..."

	sudo add-apt-repository -y ppa:wsnipex/xbmc-xvba > /dev/null 2>&1
	
	log "[x] Wsnipex xbmc-xvba PPA successfully added"
}

function distUpgrade()
{
    log "-- Updating Ubuntu installation..."

	sudo apt-get -qq update
	sudo apt-get -y -qq dist-upgrade > /dev/null 2>&1
	
	log "[x] Ubuntu installation successfully updated"
}

function installXinit()
{
    log "-- Installing xinit..."
    
	RESULT=$(sudo apt-get -y -qq install xinit)
	
	if [ $RESULT != "" ];
	then
	    log "FATAL ERROR: Xinit could not be installed '$RESULT'"
	    log "Installation terminated"
	    exit
	fi
	
	log "[x] Xinit successfully installed"
}

function installPowerManagement()
{
    log "-- Installing power management packages..."

	RESULT=$(sudo apt-get -y -qq install policykit-1 upower udisks acpi-support)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Not all power management packages could be installed '$RESULT'"
	fi
	
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/custom-actions.pkla
	sudo mkdir -p /var/lib/polkit-1/localauthority/50-local.d/
	sudo mv custom-actions.pkla /var/lib/polkit-1/localauthority/50-local.d/
	
	log "[x] Power management packages successfully installed"
}

function installAudio()
{
    log "-- Installing audio packages. !! Please make sure no used channels are muted !!..."
    
	RESULT=$(sudo apt-get -y -qq install linux-sound-base alsa-base alsa-utils pulseaudio libasound2)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Not all audio packages could be installed '$RESULT'"
	else
	    sudo alsamixer
	    log "[x] Audio packages successfully installed"
	fi
}

function confirmLircInstallation()
{
	dialog --title "Lirc installation" \
		--backtitle "$SCRIPT_TITLE" \
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
	RESULT=$(sudo apt-get -y -qq install lirc)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Lirc could not be installed '$RESULT'"
	else
        log "[x] Lirc successfully installed"
    fi
}

function cancelLircInstallation()
{
	log "[ ] Lirc installation skipped"
}

function installXbmc()
{
    log "-- Installing XBMC..."

	RESULT=$(sudo apt-get -y -qq install xbmc)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: XBMC could not be installed '$RESULT'"
	else
	    log "[x] XBMC successfully installed"  
	fi
}

function confirmEnableDirtyRegionRendering()
{
	dialog --title "Dirty region rendering" \
		--backtitle "$SCRIPT_TITLE" \
		--yesno "Do you wish to enable dirty region rendering in XBMC? (this will replace your existing advancedsettings.xml)?" 7 $DIALOG_WIDTH

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
	RESULT=$(mv dirty_region_rendering.xml $XBMC_ADVANCEDSETTINGS_FILE > /dev/null)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Dirty region rendering could not be enabled '$RESULT'"
	else
	    log "[x] XBMC dirty-region-rendering enabled"
	fi
}

function installXbmcAddonRepositoriesInstaller()
{
    log "-- Installing Addon repositories installer plugin..."

	mkdir -p $TEMP_DIRECTORY > /dev/null
	cd $TEMP_DIRECTORY
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/addons/plugin.program.repo.installer-1.0.5.tar.gz

	if [ ! -d $XBMC_ADDONS_DIR ];
	then
		mkdir -p $XBMC_ADDONS_DIR > /dev/null
	fi

    if [ ! -f ./plugin.program.repo.installer-1.0.5.tar.gz ];
    then
        log "ERROR: Addon Repositories Installer plugin could not be installed"
    else
	    tar -xvzf ./plugin.program.repo.installer-1.0.5.tar.gz -C $XBMC_ADDONS_DIR > /dev/null 2>&1
	    log "[x] Addon repositories installer plugin successfully installed"
    fi
}

function installVideoDriver()
{
    log "Installing $VIDEO_MANUFACTURER_NAME video drivers..."

	RESULT=$(sudo apt-get -y -qq install $VIDEO_DRIVER)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Video driver could not be installed '$RESULT'"
	else
	    if [ $VIDEO_MANUFACTURER == "ati" ];
	    then
		    RESULT=$(sudo aticonfig --initial -f > /dev/null)
		    RESULT=$(sudo aticonfig --sync-vsync=on > /dev/null)
		    RESULT=$(sudo aticonfig --set-pcs-u32=MCIL,HWUVD_H264Level51Support,1 > /dev/null)
		    
		    if [ $RESULT != "" ];
		    then
		        log "ERROR: Video driver configuration failed '$RESULT'"
		    fi
		
		    dialog --title "Disable underscan" \
			    --backtitle "$SCRIPT_TITLE" \
			    --yesno "Do you want to disable underscan (removes black borders)? Do this only if you're sure you need it!" 7 $DIALOG_WIDTH

		    RESPONSE=$?
		    case $RESPONSE in
		       0) disbaleAtiUnderscan;;
		       1) enableAtiUnderscan;;
		       255) log "* ATI underscan configuration skipped";;
		    esac
	    fi
	    
	    log "[x] $VIDEO_MANUFACTURER_NAME video drivers successfully installed"
	fi
}

function disbaleAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	RESULT=$(sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0 > /dev/null)
	
	if [ $RESULT != "" ];
    then
        log "ERROR: Video driver configuration failed '$RESULT'"
    else
        log "[ ] Underscan successfully disabled"
    fi
}

function enableAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	RESULT=$(sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,1 > /dev/null)
	
	if [ $RESULT != "" ];
    then
        log "ERROR: Video driver configuration failed '$RESULT'"
    else
        log "[x] Underscan successfully enabled"
    fi
}

function installXbmcAutorunScript()
{
    log "-- Installing XBMC autorun script..."
    
    mkdir -p $TEMP_DIRECTORY > /dev/null
	cd $TEMP_DIRECTORY
	wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/xbmc_init_script > /dev/null
	
	if [ ! -f ./xbmc_init_script ];
	then
	    log "ERROR: Download of XBMC autorun script failed"
	else
	    if [ -f $INIT_FILE ];
	    then
		    sudo rm $INIT_FILE > /dev/null
	    fi

	    sudo mv ./xbmc_init_script $INIT_FILE > /dev/null
	    sudo chmod a+x /etc/init.d/xbmc > /dev/null
	    RESULT=$(sudo update-rc.d xbmc defaults > /dev/null)
	    
	    if [ $RESULT != "" ];
	    then
	        log "ERROR: XBMC autorun could not be activated"
	    else
	        log "[x] XBMC autorun succesfully configured"
	    fi
	fi
}

function installXbmcBootScreen()
{
    log "-- Installing XBMC boot screen..."

	RESULT=$(sudo apt-get -y -qq install plymouth-label v86d)
	
	if [ $RESULT != "" ];
	then
	    log "ERROR: Boot screen installation requirements could not be installed"
	else
	    mkdir -p $TEMP_DIRECTORY > /dev/null
	    cd $TEMP_DIRECTORY
	    wget -q https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/plymouth-theme-xbmc-logo.deb
	    
	    if [ ! -f ./plymouth-theme-xbmc-logo.deb ];
	    then
	        log "ERROR: Download of XBMC boot screen package failed"
	    else
	        RESULT=$(sudo dpkg -i plymouth-theme-xbmc-logo.deb > /dev/null)
	        
	        if [ $RESULT != "" ];
	        then
	            log "ERROR: XBMC boot screen could not be installed"
	        else
	            if [ -f /etc/initramfs-tools/conf.d/splash ];
	            then
		            sudo rm /etc/initramfs-tools/conf.d/splash > /dev/null
	            fi

	            sudo touch /etc/initramfs-tools/conf.d/splash > /dev/null
	            sudo sh -c 'echo "FRAMEBUFFER=y" >> /etc/initramfs-tools/conf.d/splash' > /dev/null
	            sudo update-grub > /dev/null 2>&1
	            sudo update-initramfs -u > /dev/null 2>&1
	            
	            log "[x] XBMC boot screen successfully installed"
	        fi
	    fi
	fi
	
	
}

function reconfigureXServer()
{
    log "-- Configuring X-server..."
    
    if [ ! -f $XWRAPPER_FILE ];
    then
        sudo touch $XWRAPPER_FILE
    fi

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
	
	log "[x] X-server successfully configured"
}

function cleanUp()
{
    log "-- Cleaning up..."

	sudo apt-get -y autoclean > /dev/null
	sudo apt-get -y autoremove > /dev/null
	sudo rm -r $TEMP_DIRECTORY > /dev/null
	rm $HOME_DIRECTORY$THIS_FILE
}

function rebootMachine()
{
    log "-- Rebooting system..."

	dialog --title "Installation complete" \
		--backtitle "$SCRIPT_TITLE" \
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
	clear
	exit
}

control_c()
{
  quit
}

## ------- END functions -------

clear

echo ""
echo ""

installDependencies
showDialog "Welcome to the XBMC minimal installation script.\n\nSome parts may take a while to install depending on your internet connection speed.\nPlease be patient or exit with CTRL+C!"
trap control_c SIGINT
hasRequiredParams $VIDEO_MANUFACTURER

declare -a METHODS=("fixLocaleBug" "applyXbmcNiceLevelPermissions" "addUserToRequiredGroups" "addXbmcPpa" "distUpgrade" "installXinit" "installPowerManagement" "installAudio" "confirmLircInstallation" "installXbmc" "confirmEnableDirtyRegionRendering" "installXbmcAddonRepositoriesInstaller" "installVideoDriver" "installXbmcAutoRunScript" "installXbmcBootScreen" "reconfigureXServer" "cleanUp" "rebootMachine")

dialog --title "Configring Ubuntu and Installing XBMC" --gauge "Installation initializing" 35 $DIALOG_WIDTH < <(
    n=${#METHODS[*]}; 
    i=0
   
    for f in "${METHODS[@]}"
    do
        PCT=$(( 100*(++i)/n ))
        
cat <<EOF
XXX
$PCT
"$LOG_TEXT"
XXX
EOF
        
    eval "$f"
    
cat <<EOF
XXX
$PCT
"$LOG_TEXT"
XXX
EOF
    
  done
)
