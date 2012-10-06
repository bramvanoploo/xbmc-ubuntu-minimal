#!/bin/bash

THIS_FILE=$0
SCRIPT_VERSION="2.3"

VIDEO_MANUFACTURER=""
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
GRUB_CONFIG_FILE="/etc/default/grub"
GRUB_CONFIG_BACKUP_FILE="/etc/default/grub.bak"
SYSTEM_LIMITS_FILE="/etc/security/limits.conf"
INITRAMFS_SPLASH_FILE="/etc/initramfs-tools/conf.d/splash"
INITRAMFS_MODULES_FILE="/etc/initramfs-tools/modules"
INITRAMFS_MODULES_BACKUP_FILE="/etc/initramfs-tools/modules.bak"
XWRAPPER_CONFIG_FILE="/etc/X11/Xwrapper.config"
POWERMANAGEMENT_DIR="/var/lib/polkit-1/localauthority/50-local.d/"

XBMC_PPA="ppa:wsnipex/xbmc-xvba"
HTS_TVHEADEND_PPA="ppa:jabbors/hts-stable"
OSCAM_PPA="ppa:oscam/ppa"

LOG_TEXT="\n"
LOG_FILE=$HOME_DIRECTORY"xbmc_installation.log"
DIALOG_WIDTH=70
SCRIPT_TITLE="XBMC installation script v$SCRIPT_VERSION for Ubuntu 12.10 by Bram van Oploo :: bram@sudo-systems.com :: www.sudo-systems.com"

## ------ START functions ---------

function log()
{
    echo "$@" >> $LOG_FILE
	LOG_TEXT="$LOG_TEXT$@\n"
	
	dialog --title "Ubuntu configuration and XBMC installation in progress..." --backtitle "$SCRIPT_TITLE" --infobox "$LOG_TEXT" 34 $DIALOG_WIDTH
}

function showInfo()
{
    echo "$@" >> $LOG_FILE
	LOG_TEXT="$LOG_TEXT$@\n"

    dialog --title "Installing..." --backtitle "$SCRIPT_TITLE" --infobox "\n$@" 5 $DIALOG_WIDTH
}

function showError()
{
    echo "$@" >> $LOG_FILE
	LOG_TEXT="$LOG_TEXT$@\n"

    dialog --title "Error" --backtitle "$SCRIPT_TITLE" --msgbox "$@" 6 $DIALOG_WIDTH
}

function showDialog()
{
	dialog --title "XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 12 $DIALOG_WIDTH
}

function showErrorDialog()
{
	dialog --title "ERROR" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 8 $DIALOG_WIDTH
}

function update()
{
    sudo apt-get update > /dev/null 2>&1
}

function createFile()
{
    FILE="$1"
    IS_ROOT=$2
    REMOVE_IF_EXISTS=$3
    
    if [ -e $FILE ]; then
        if [[ $REMOVE_IF_EXISTS -eq 1 ]]; then
            sudo rm $FILE > /dev/null
        fi
    else
        if [[ $IS_ROOT -eq 0 ]]; then
            touch $FILE > /dev/null
        else
            sudo touch $FILE > /dev/null
        fi
    fi
}

function createDirectory()
{
    DIRECTORY="$1"
    GOTO_DIRECTORY=$2
    
    if [ ! -d $DIRECTORY ];
    then
        sudo mkdir -p "$DIRECTORY" > /dev/null 2>&1
    fi
    
    if [[ $GOTO_DIRECTORY -eq 1 ]];
    then
        cd $DIRECTORY
    fi
}

function handleFileBackup()
{
    FILE="$@"
    BACKUP="$@.bak"

    if [ -e $BACKUP ];
	then
		sudo rm "$FILE" > /dev/null 2>&1
		sudo cp "$BACKUP" "$FILE" > /dev/null 2>&1
	else
		sudo cp "$FILE" "$BACKUP" > /dev/null 2>&1
	fi
}

function appendToFile()
{
    FILE="$1"
    CONTENT="$2"
    echo "$CONTENT" | sudo tee -a "$FILE" > /dev/null 2>&1
}

function addRepository()
{
    IS_ADDED=false
    REPOSITORY=$@
    KEYSTORE_DIR=$HOME_DIRECTORY".gnupg/"
    createDirectory "$KEYSTORE_DIR"
    sudo add-apt-repository -y $REPOSITORY > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        update
        IS_ADDED=1
        showInfo "$REPOSITORY repository successfully added"
    else
        showError "Repository $REPOSITORY could not be added (error code $?)"
    fi
}

function isPackageInstalled()
{
    IS_INSTALLED=false
    sudo dpkg-query -l $@ > /dev/null 2>&1
    
    if [[ $? -eq 0 ]];
    then
        IS_INSTALLED=1
    fi
}

function aptInstall()
{
    INSTALLATION_SUCCESSFULL=1
    PACKAGES="$@"
    IFS=" " read -ra A_PACKAGES <<< "$PACKAGES"
    
    for i in "${A_PACKAGES[@]}"; do
        PACKAGE=${A_PACKAGES[$i]}
        isPackageInstalled $PACKAGE
        
        if [ $IS_INSTALLED ]; then
            showInfo "Skipping installation of $PACKAGE. Already installed."
        else
            sudo apt-get -y install $PACKAGE > /dev/null 2>&1
            
            if [[ $? -eq 0 ]]; then
                showInfo "$PACKAGE successfully installed"
            else
                INSTALLATION_SUCCESSFULL=false
                showError "$PACKAGE could not be installed (error code: $?)"
            fi 
        fi
    done
}

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

function move()
{
    IS_MOVED=false
    SOURCE=$1
    DESTINATION=$2
    
    if [ -e $SOURCE ];
	then
	    sudo mv "$SOURCE" "$DESTINATION" > /dev/null 2>&1
	    
	    if [[ $? -eq 0 ]]; then
	        IS_MOVED=1
	    fi
	else
	    showError "$SOURCE could not be moved to $DESTINATION because the file does not exist"
	fi
}

------------------------------

function installDependencies()
{
    echo "-- Installing installation dependencies..."
    echo ""

	sudo apt-get -y install dialog software-properties-common > /dev/null 2>&1
}

function fixLocaleBug()
{
    createFile $ENVIRONMENT_FILE
    handleFileBackup $ENVIRONMENT_FILE
    appendToFile $ENVIRONMENT_FILE "LC_MESSAGES=\"C\""
    appendToFile $ENVIRONMENT_FILE "LC_ALL=\"en_US.UTF-8\""
	showInfo "Locale environment bug fixed"
}

function applyXbmcNiceLevelPermissions()
{
	createFile $SYSTEM_LIMITS_FILE
    appendToFile $SYSTEM_LIMITS_FILE "$USER             -       nice            -1"
	showInfo "Allowed XBMC to prioritize threads"
}

function addUserToRequiredGroups()
{
	sudo adduser $USER video > /dev/null 2>&1
	sudo adduser $USER audio > /dev/null 2>&1
	sudo adduser $USER users > /dev/null 2>&1
	showInfo "XBMC user added to required groups"
}

function addXbmcPpa()
{
    showInfo "Adding Wsnipex xbmc-xvba PPA..."
	addRepository "$XBMC_PPA"
}

function distUpgrade()
{
    showInfo "Updating Ubuntu with latest packages (may take a while)..."
	update
	sudo apt-get -y dist-upgrade > /dev/null 2>&1
	showInfo "Ubuntu installation updated"
}

function installXinit()
{
    showInfo "Installing xinit..."
    aptInstall xinit
}

function installPowerManagement()
{
    showInfo "Installing power management packages..."
    createDirectory "$TEMP_DIRECTORY" 1
	aptInstall policykit-1 upower udisks acpi-support
	download "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/custom-actions.pkla"
	createDirectory "$POWERMANAGEMENT_DIR"
    move $TEMP_DIRECTORY"custom-actions.pkla" "$POWERMANAGEMENT_DIR"
}

function installAudio()
{
    showInfo "Installing audio packages....\n!! Please make sure no used channels are muted !!"
	aptInstall linux-sound-base alsa-base alsa-utils libasound2
    sudo alsamixer
}

function installLirc()
{
    clear
    echo ""
    echo "Installing lirc..."
    echo ""
    echo "------------------"
    echo ""

	aptInstall lirc
}

function installTvHeadend()
{
    showInfo "Adding jabbors hts-stable PPA..."
	addRepository "$HTS_TVHEADEND_PPA"

    clear
    echo ""
    echo "Installing tvheadend..."
    echo ""
    echo "------------------"
    echo ""
    
    aptInstall tvheadend
}

function installOscam()
{
    showInfo "Adding oscam PPA..."
	addRepository "$OSCAM_PPA"

    if [ $IS_ADDED ]; then
        showInfo "Installing oscam..."
        aptInstall oscam-svn
    fi
}

function installXbmc()
{
    showInfo "Installing XBMC..."
    isPackageInstalled xbmc
    aptInstall xbmc
}

function enableDirtyRegionRendering()
{
    showInfo "Enabling XBMC dirty region rendering..."
    handleFileBackup $XBMC_ADVANCEDSETTINGS_FILE
	
	createDirectory $TEMP_DIRECTORY 1
	download "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/dirty_region_rendering.xml"
	createDirectory $XBMC_USERDATA_DIR
	move $TEMP_DIRECTORY"dirty_region_rendering.xml" "$XBMC_ADVANCEDSETTINGS_FILE"
	
	if [ $IS_MOVED ]; then
        showInfo "XBMC dirty region rendering enabled"
    else
        showError "XBMC dirty region rendering could not be enabled"
    fi
}

function installXbmcAddonRepositoriesInstaller()
{
    showInfo "Installing Addon Repositories Installer addon..."
	createDirectory "$TEMP_DIRECTORY" 1
	download "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/addons/plugin.program.repo.installer-1.0.5.tar.gz"
    createDirectory "$XBMC_ADDONS_DIR"

    if [ -e $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" ]; then
        tar -xvzf $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" -C "$XBMC_ADDONS_DIR" > /dev/null 2>&1
        
        if [[ $? -eq 0 ]]; then
	        showInfo "Addon Repositories Installer addon successfully installed"
	    else
	        showError "Addon Repositories Installer addon could not be installed (error code: $?)"
	    fi
    else
	    showError "Addon Repositories Installer addon could not be downloaded"
    fi
}

function configureAtiDriver()
{
    sudo aticonfig --initial -f > /dev/null 2>&1
    sudo aticonfig --sync-vsync=on > /dev/null 2>&1
    sudo aticonfig --set-pcs-u32=MCIL,HWUVD_H264Level51Support,1 > /dev/null 2>&1
}

function disbaleAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0 > /dev/null 2>&1
    showInfo "Underscan successfully disabled"
}

function enableAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,1 > /dev/null 2>&1
    showInfo "Underscan successfully enabled"
}

function installVideoDriver()
{
    showInfo "Installing $VIDEO_MANUFACTURER_NAME video drivers (may take a while)..."
    aptInstall $VIDEO_DRIVER

    if [ $INSTALLATION_SUCCESSFULL ]; then
        if [ $VIDEO_MANUFACTURER -eq "ati" ]; then
            configureAtiDriver

            dialog --title "Disable underscan" \
	            --backtitle "$SCRIPT_TITLE" \
	            --yesno "Do you want to disable underscan (removes black borders)? Do this only if you're sure you need it!" 7 $DIALOG_WIDTH

            RESPONSE=$?
            case $RESPONSE in
                0) 
                    disbaleAtiUnderscan
                    ;;
                1) 
                    enableAtiUnderscan
                    ;;
                255) 
                    showInfo "ATI underscan configuration skipped"
                    ;;
            esac
        fi
        
        showInfo "$VIDEO_MANUFACTURER_NAME video drivers successfully installed and configured"
    fi
}

function installXbmcAutorunScript()
{
    showInfo "Installing XBMC autorun support..."
    createDirectory "$TEMP_DIRECTORY" 1
	download "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/xbmc_init_script"
	
	if [ -e $TEMP_DIRECTORY"xbmc_init_script" ]; then
	    if [ -e $INIT_FILE ]; then
		    sudo rm $INIT_FILE > /dev/null
	    fi
	    
	    move $TEMP_DIRECTORY"xbmc_init_script" "$INIT_FILE"
	    sudo chmod a+x "$INIT_FILE" > /dev/null
	    sudo update-rc.d xbmc defaults > /dev/null
	    
	    if [[ $? -eq 0 ]]; then
            showInfo "XBMC autorun succesfully configured"
        else
            showError "XBMC outrun script could not be activated (error code: $?)"
        fi
	else
	    showError "Download of XBMC autorun script failed"
	fi
}

function installXbmcBootScreen()
{
    showInfo "Installing XBMC boot screen (please be patient)..."
    isPackageInstalled plymouth-theme-xbmc-logo

    if [ ! $IS_INSTALLED ]; then
	    aptInstall plymouth-label v86d
        createDirectory $TEMP_DIRECTORY 1
        download "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/plymouth-theme-xbmc-logo.deb"
        
        if [ -e $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" ]; then
            sudo dpkg -i $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" > /dev/null
            createFile "$INITRAMFS_SPLASH_FILE" 1 0
            appendToFile "$INITRAMFS_SPLASH_FILE" "FRAMEBUFFER=y"
            handleFileBackup "$GRUB_CONFIG_FILE"
	        appendToFile "$GRUB_CONFIG_FILE" "video=uvesafb:mode_option=1366x768-24,mtrr=3,scroll=ywrap"
	        appendToFile "$GRUB_CONFIG_FILE" "GRUB_GFXMODE=1366x768"
            handleFileBackup "$INITRAMFS_MODULES_FILE"
	        appendToFile "$INITRAMFS_MODULES_FILE" "uvesafb mode_option=1366x768-24 mtrr=3 scroll=ywrap"
            sudo update-grub > /dev/null 2>&1
            sudo update-initramfs -u > /dev/null
            
            if [[ $? -eq 0 ]]; then
                showInfo "XBMC boot screen successfully activated"
            else
                showError "XBMC boot screen could not be activated (error code: $?)"
            fi
        else
            showError "Download of XBMC boot screen package failed"
        fi
    else
        showInfo "Skipping. XBMC boot screen already installed"
    fi
}

function reconfigureXServer()
{
    showInfo "Configuring X-server..."
    handleFileBackup "$XWRAPPER_FILE"
    createFile "$XWRAPPER_FILE" 1 1
	appendToFile "$XWRAPPER_FILE" "allowed_users=anybody"
	showInfo "X-server successfully configured"
}

function selectAdditionalOptions()
{
    cmd=(dialog --title "Optional packages and features" 
        --backtitle "$SCRIPT_TITLE" 
        --checklist "Plese select optional packages to install:" 
        15 $DIALOG_WIDTH 5)
        
    options=(1 "Lirc (IR remote support)" off
            2 "Hts tvheadend (live TV backend)" off
            3 "Oscam (live HDTV decryption tool)" off
            4 "XBMC Dirty region rendering (improved performance)" on
            5 "XBMC Addon Repositories Installer addon" on)
            
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case ${choice//\"/} in
            1)
                installLirc
                ;;
            2)
                installTvHeadend 
                ;;
            3)
                installOscam 
                ;;
            4)
                enableDirtyRegionRendering 
                ;;
            5)
                installXbmcAddonRepositoriesInstaller 
                ;;
        esac
    done
}

function selectVideoDriver()
{
    cmd=(dialog --backtitle "Video driver installation"
        --radiolist "Select your video chipset manufacturer (required):" 
        10 $DIALOG_WIDTH 3)
        
    options=(1 "NVIDIA" on
         2 "ATI (series >= 5xxx)" off
         3 "Intel" off)
         
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case ${choice//\"/} in
        1)
            VIDEO_MANUFACTURER="nvidia"
		    VIDEO_DRIVER="nvidia-current"
		    VIDEO_MANUFACTURER_NAME="NVIDIA"
		    installVideoDriver
            ;;
        2)
            VIDEO_MANUFACTURER="ati"
		    VIDEO_DRIVER="fglrx"
		    VIDEO_MANUFACTURER_NAME="ATI"
		    installVideoDriver
            ;;
        3)
            VIDEO_MANUFACTURER="intel"
		    VIDEO_DRIVER="i965-va-driver"
		    VIDEO_MANUFACTURER_NAME="Intel"
		    installVideoDriver
            ;;
        *)
            selectVideoDriver
            ;;
    esac
}

function cleanUp()
{
    showInfo "Cleaning up..."
	sudo apt-get -y autoclean > /dev/null 2>&1
	sudo apt-get -y autoremove > /dev/null 2>&1
	#sudo rm -R "$TEMP_DIRECTORY" > /dev/null 2>&1
	rm "$HOME_DIRECTORY$THIS_FILE"
}

function rebootMachine()
{
    showInfo "Reboot system..."
	dialog --title "Installation complete" \
		--backtitle "$SCRIPT_TITLE" \
		--yesno "Do you want to reboot now?" 7 $DIALOG_WIDTH

	case $? in
        0)
            clear
            echo ""
            echo "Installation complete. Rebooting..."
            echo ""
            sudo reboot now > /dev/null 2>&1
	        ;;
	    1) 
            quit
	        ;;
	    255) 
	        quit
	        ;;
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

createFile "$LOG_FILE" 0 1

echo ""
installDependencies
echo "Loading installer..."
showDialog "Welcome to the XBMC minimal installation script. Some parts may take a while to install depending on your internet connection speed.\n\nPlease be patient..."
trap control_c SIGINT

fixLocaleBug
applyXbmcNiceLevelPermissions
addUserToRequiredGroups
addXbmcPpa
distUpgrade
selectVideoDriver
installXinit
installXbmc
installXbmcAutorunScript
installXbmcBootScreen
reconfigureXServer
installPowerManagement
installAudio
selectAdditionalOptions
cleanUp
rebootMachine
