#!/bin/bash
#
# @author   Bram van Oploo
# @date     2012-10-06
# @version  2.4
#

THIS_FILE=$0
SCRIPT_VERSION="2.4"

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
XBMC_KEYMAPS_DIR=$XBMC_USERDATA_DIR"keymaps/"
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
DOWNLOAD_URL="https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.10/download/"

XBMC_PPA="ppa:wsnipex/xbmc-xvba"
HTS_TVHEADEND_PPA="ppa:jabbors/hts-stable"
OSCAM_PPA="ppa:oscam/ppa"

LOG_FILE=$HOME_DIRECTORY"xbmc_installation.log"
DIALOG_WIDTH=70
SCRIPT_TITLE="XBMC installation script v$SCRIPT_VERSION for Ubuntu 12.10 by Bram van Oploo :: bram@sudo-systems.com :: www.sudo-systems.com"

## ------ START functions ---------

function showInfo()
{
    CUR_DATE=$(date +%Y-%m-%d" "%H:%M)
    echo "$CUR_DATE - INFO :: $@" >> $LOG_FILE
    dialog --title "Installing..." --backtitle "$SCRIPT_TITLE" --infobox "\n$@" 5 $DIALOG_WIDTH
}

function showError()
{
    CUR_DATE=$(date +%Y-%m-%d" "%H:%M)
    echo "$CUR_DATE - ERROR :: $@" >> $LOG_FILE
    dialog --title "Error" --backtitle "$SCRIPT_TITLE" --msgbox "$@" 8 $DIALOG_WIDTH
}

function showDialog()
{
	dialog --title "XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 12 $DIALOG_WIDTH
}

function update()
{
    sudo apt-get update > /dev/null 2>&1
}

function createFile()
{
    FILE="$1"
    IS_ROOT="$2"
    REMOVE_IF_EXISTS="$3"
    
    if [ -e "$FILE" ] && [ "$REMOVE_IF_EXISTS" == "1" ]; then
        sudo rm "$FILE" > /dev/null
    else
        if [ "$IS_ROOT" == "0" ]; then
            touch "$FILE" > /dev/null
        else
            sudo touch "$FILE" > /dev/null
        fi
    fi
}

function createDirectory()
{
    DIRECTORY="$1"
    GOTO_DIRECTORY="$2"
    IS_ROOT="$3"
    
    if [ ! -d "$DIRECTORY" ];
    then
        if [ "$IS_ROOT" == "0" ]; then
            mkdir -p "$DIRECTORY" > /dev/null 2>&1
        else
            sudo mkdir -p "$DIRECTORY" > /dev/null 2>&1
        fi
    fi
    
    if [ "$GOTO_DIRECTORY" == "1" ];
    then
        cd $DIRECTORY
    fi
}

function handleFileBackup()
{
    FILE="$1"
    BACKUP="$1.bak"
    IS_ROOT="$2"
    DELETE_ORIGINAL="$3"

    if [ -e "$BACKUP" ];
	then
	    if [ "$IS_ROOT" == "1" ]; then
	        sudo rm "$FILE" > /dev/null 2>&1
		    sudo cp "$BACKUP" "$FILE" > /dev/null 2>&1
	    else
		    rm "$FILE" > /dev/null 2>&1
		    cp "$BACKUP" "$FILE" > /dev/null 2>&1
		fi
	else
	    if [ "$IS_ROOT" == "1" ]; then
		    sudo cp "$FILE" "$BACKUP" > /dev/null 2>&1
		else
		    cp "$FILE" "$BACKUP" > /dev/null 2>&1
		fi
	fi
	
	if [ "$DELETE_ORIGINAL" == "1" ]; then
	    sudo rm "$FILE" > /dev/null 2>&1
	fi
}

function appendToFile()
{
    FILE="$1"
    CONTENT="$2"
    IS_ROOT="$3"
    
    if [ "$IS_ROOT" == "0" ]; then
        echo "$CONTENT" | tee -a "$FILE" > /dev/null 2>&1
    else
        echo "$CONTENT" | sudo tee -a "$FILE" > /dev/null 2>&1
    fi
}

function addRepository()
{
    REPOSITORY=$@
    KEYSTORE_DIR=$HOME_DIRECTORY".gnupg/"
    createDirectory "$KEYSTORE_DIR" 0 0
    sudo add-apt-repository -y $REPOSITORY > /dev/null 2>&1

    if [ "$?" == "0" ]; then
        update
        showInfo "$REPOSITORY repository successfully added"
        echo 1
    else
        showError "Repository $REPOSITORY could not be added (error code $?)"
        echo 0
    fi
}

function isPackageInstalled()
{
    PACKAGE=$@
    sudo dpkg-query -l $PACKAGE > /dev/null 2>&1
    
    if [ "$?" == "0" ]; then
        echo 1
    else
        echo 0
    fi
}

function aptInstall()
{
    PACKAGE=$@
    IS_INSTALLED=$(isPackageInstalled $PACKAGE)

    if [ "$IS_INSTALLED" == "1" ]; then
        showInfo "Skipping installation of $PACKAGE. Already installed."
        echo 1
    else
        sudo apt-get -f install > /dev/null 2>&1
        sudo apt-get -y install $PACKAGE > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
            showInfo "$PACKAGE successfully installed"
            echo 1
        else
            showError "$PACKAGE could not be installed (error code: $?)"
            echo 0
        fi 
    fi
}

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

function move()
{
    SOURCE="$1"
    DESTINATION="$2"
    IS_ROOT="$3"
    
    if [ -e "$SOURCE" ];
	then
	    if [ "$IS_ROOT" == "0" ]; then
	        mv "$SOURCE" "$DESTINATION" > /dev/null 2>&1
	    else
	        sudo mv "$SOURCE" "$DESTINATION" > /dev/null 2>&1
	    fi
	    
	    if [ "$?" == "0" ]; then
	        echo 1
	    else
	        showError "$SOURCE could not be moved to $DESTINATION (error code: $?)"
	        echo 0
	    fi
	else
	    showError "$SOURCE could not be moved to $DESTINATION because the file does not exist"
	    echo 0
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
    handleFileBackup $ENVIRONMENT_FILE 1
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
	IS_ADDED=$(addRepository "$XBMC_PPA")
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
    IS_INSTALLED=$(aptInstall xinit)
}

function installPowerManagement()
{
    showInfo "Installing power management packages..."
    createDirectory "$TEMP_DIRECTORY" 1 0
    IS_INSTALLED=$(aptInstall policykit-1)
    IS_INSTALLED=$(aptInstall upower)
    IS_INSTALLED=$(aptInstall udisks)
    IS_INSTALLED=$(aptInstall acpi-support)
	download $DOWNLOAD_URL"custom-actions.pkla"
	createDirectory "$POWERMANAGEMENT_DIR"
    IS_MOVED=$(move $TEMP_DIRECTORY"custom-actions.pkla" "$POWERMANAGEMENT_DIR")
}

function installAudio()
{
    showInfo "Installing audio packages....\n!! Please make sure no used channels are muted !!"
    IS_INSTALLED=$(aptInstall linux-sound-base)
    IS_INSTALLED=$(aptInstall alsa-base)
    IS_INSTALLED=$(aptInstall alsa-utils)
    IS_INSTALLED=$(aptInstall libasound2)
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
    
	sudo apt-get -y install lirc
	
	if [ "$?" == "0" ]; then
        showInfo "Lirc successfully installed"
    else
        showError "Lirc could not be installed (error code: $?)"
    fi
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

    sudo apt-get -y install tvheadend
    
    if [ "$?" == "0" ]; then
        showInfo "TvHeadend successfully installed"
    else
        showError "TvHeadend could not be installed (error code: $?)"
    fi
}

function installOscam()
{
    showInfo "Adding oscam PPA..."
    addRepository "$OSCAM_PPA"

    showInfo "Installing oscam..."
    IS_INSTALLED=$(aptInstall oscam-svn)
}

function installXbmc()
{
    showInfo "Installing XBMC..."
    IS_INSTALLED=$(aptInstall xbmc)
}

function enableDirtyRegionRendering()
{
    showInfo "Enabling XBMC dirty region rendering..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	handleFileBackup $XBMC_ADVANCEDSETTINGS_FILE 0 1
	download $DOWNLOAD_URL"dirty_region_rendering.xml"
	createDirectory "$XBMC_USERDATA_DIR" 0 0
	IS_MOVED=$(move $TEMP_DIRECTORY"dirty_region_rendering.xml" "$XBMC_ADVANCEDSETTINGS_FILE")

	if [ "$IS_MOVED" == "1" ]; then
        showInfo "XBMC dirty region rendering enabled"
    else
        showError "XBMC dirty region rendering could not be enabled"
    fi
}

function installXbmcAddonRepositoriesInstaller()
{
    showInfo "Installing Addon Repositories Installer addon..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"plugin.program.repo.installer-1.0.5.tar.gz"
    createDirectory "$XBMC_ADDONS_DIR" 0 0

    if [ -e $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" ]; then
        tar -xvzf $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" -C "$XBMC_ADDONS_DIR" > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
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
    IS_INSTALLED=$(aptInstall $VIDEO_DRIVER)

    if [ "$IS_INSTALLED" == "1"]; then
        if [ "$VIDEO_MANUFACTURER" == "ati" ]; then
            configureAtiDriver

            dialog --title "Disable underscan" \
                --backtitle "$SCRIPT_TITLE" \
                --yesno "Do you want to disable underscan (removes black borders)? Do this only if you're sure you need it!" 7 $DIALOG_WIDTH

            RESPONSE=$?
            case ${RESPONSE//\"/} in
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

function installAutomaticDistUpgrade()
{
    showInfo "Enabling automatic system upgrade..."
	
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"dist_upgrade.sh"
	IS_MOVED=$(move $TEMP_DIRECTORY"dist_upgrade.sh" "/etc/cron.d/" 1)
	
	if [ "$IS_MOVED" == "1" ]; then
	    IS_INSTALLED=$(aptInstall cron)
	    sudo chmod +x "/etc/cron.d/dist_upgrade.sh" > /dev/null 2>&1
	    handleFileBackup "/etc/crontab" 1
	    appendToFile "/etc/crontab" "0 */4  * * * root  /etc/cron.d/dist_upgrade.sh >> /var/log/updates.log"
	else
	    showError "Automatic system upgrade interval could not be enabled"
	fi
}

function installXbmcAutorunScript()
{
    showInfo "Installing XBMC autorun support..."
    createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"xbmc_init_script"
	
	if [ -e $TEMP_DIRECTORY"xbmc_init_script" ]; then
	    if [ -e $INIT_FILE ]; then
		    sudo rm $INIT_FILE > /dev/null
	    fi
	    
	    IS_MOVED=$(move $TEMP_DIRECTORY"xbmc_init_script" "$INIT_FILE")

	    if [ "$IS_MOVED" == "1" ]; then
	        sudo chmod a+x "$INIT_FILE" > /dev/null
	        sudo update-rc.d xbmc defaults > /dev/null
	        
	        if [ "$?" == "0" ]; then
                showInfo "XBMC autorun succesfully configured"
            else
                showError "XBMC autorun script could not be activated (error code: $?)"
            fi
	    else
	        showError "XBMC autorun script could not be installed"
	    fi
	else
	    showError "Download of XBMC autorun script failed"
	fi
}

function installNyxBoardKeymap()
{
    showInfo "Applying Pulse-Eight Motorola NYXboard advanced keymap..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"nyxboard.tar.gz"
    createDirectory "$XBMC_KEYMAPS_DIR" 0 0

    if [ -e $XBMC_KEYMAPS_DIR"keyboard.xml" ]; then
        handleFileBackup $XBMC_KEYMAPS_DIR"keyboard.xml" 0 1
    fi

    if [ -e $TEMP_DIRECTORY"nyxboard.tar.gz" ]; then
        tar -xvzf $TEMP_DIRECTORY"nyxboard.tar.gz" -C "$XBMC_KEYMAPS_DIR" > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
	        showInfo "Pulse-Eight Motorola NYXboard advanced keymap successfully applied"
	    else
	        showError "Pulse-Eight Motorola NYXboard advanced keymap could not be applied (error code: $?)"
	    fi
    else
	    showError "Pulse-Eight Motorola NYXboard advanced keymap could not be downloaded"
    fi
}

function installXbmcBootScreen()
{
    showInfo "Installing XBMC boot screen (please be patient)..."
    IS_INSTALLED=$(aptInstall plymouth-label)
    IS_INSTALLED=$(aptInstall v86d)
    createDirectory "$TEMP_DIRECTORY" 1 0
    download $DOWNLOAD_URL"plymouth-theme-xbmc-logo.deb"
    
    if [ -e $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" ]; then
        sudo dpkg -i $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" > /dev/null
        handleFileBackup "$INITRAMFS_SPLASH_FILE" 1 1
        createFile "$INITRAMFS_SPLASH_FILE" 1 1
        appendToFile "$INITRAMFS_SPLASH_FILE" "FRAMEBUFFER=y"
        showInfo "XBMC boot screen successfully installed"
    else
        showError "Download of XBMC boot screen package failed"
    fi
}

function applyScreenResolution()
{
    RESOLUTION="$1"
    
    showInfo "Applying screen resultion of $RESOLUTION..."
    handleFileBackup "$GRUB_CONFIG_FILE" 1 0
    appendToFile "$GRUB_CONFIG_FILE" "video=uvesafb:mode_option=$RESOLUTION-24,mtrr=3,scroll=ywrap"
    appendToFile "$GRUB_CONFIG_FILE" "GRUB_GFXMODE=$RESOLUTION"
    handleFileBackup "$INITRAMFS_MODULES_FILE" 1 0
    appendToFile "$INITRAMFS_MODULES_FILE" "uvesafb mode_option=$RESOLUTION-24 mtrr=3 scroll=ywrap"
    sudo update-grub > /dev/null 2>&1
    sudo update-initramfs -u > /dev/null
    
    if [ "$?" == "0" ]; then
        showInfo "Screen resultion of $RESOLUTION successfully applied"
    else
        showError "Screen resultion of $RESOLUTION could not be applied"
    fi
}

function installLmSensors()
{
    showInfo "Installing temperature monitoring package (apply all defaults)..."
    aptInstall lm-sensors
    clear
    sudo sensors-detect
    
    if [ ! -e "$XBMC_ADVANCEDSETTINGS_FILE" ]; then
	    createDirectory "$TEMP_DIRECTORY" 1 0
	    download $DOWNLOAD_URL"temperature_monitoring.xml"
	    createDirectory "$XBMC_USERDATA_DIR" 0 0
	    IS_MOVED=$(move $TEMP_DIRECTORY"temperature_monitoring.xml" "$XBMC_ADVANCEDSETTINGS_FILE")

	    if [ "$IS_MOVED" == "1" ]; then
            showInfo "Temperature monitoring successfully enabled in XBMC"
        else
            showError "Temperature monitoring could not be enabled in XBMC"
        fi
    fi
    
    showInfo "Temperature monitoring successfully configured"
}

function reconfigureXServer()
{
    showInfo "Configuring X-server..."
    handleFileBackup "$XWRAPPER_FILE" 1
    createFile "$XWRAPPER_FILE" 1 1
	appendToFile "$XWRAPPER_FILE" "allowed_users=anybody"
	showInfo "X-server successfully configured"
}

function selectXbmcTweaks()
{
    cmd=(dialog --title "Optional XBMC tweaks and additions" 
        --backtitle "$SCRIPT_TITLE" 
        --checklist "Plese select to install or apply:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "Enable dirty region rendering (improved performance)" on
            2 "Enable temperature monitoring (press Enter for in all cases asked)" on
            3 "Install Addon Repositories Installer addon" on
            4 "Apply improved Pulse-Eight Motorola NYXboard keymap" off)
            
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case ${choice//\"/} in
            1)
                enableDirtyRegionRendering
                ;;
            2)
                installLmSensors
                ;;
            3)
                installXbmcAddonRepositoriesInstaller 
                ;;
            4)
                installNyxBoardKeymap 
                ;;
        esac
    done
}

function selectScreenResolution()
{
    cmd=(dialog --backtitle "Select screen resolution (required)"
        --radiolist "Please select your screen resolution or the one sligtly lower then it can handle if an exact match isn't availabel:" 
        10 $DIALOG_WIDTH 5)
        
    options=(1 "720 x 480 (NTSC)" off
            2 "720 x 576 (PAL)" off
            3 "1280 × 720 (HD Ready)" off
            4 "1366 x 768 (HD Ready)" off
            5 "1920 x 1080 (Full HD)" off)
         
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case ${choice//\"/} in
        1)
            applyScreenResolution "720x480"
            ;;
        2)
            applyScreenResolution "720x576"
            ;;
        3)
            applyScreenResolution "1280×720"
            ;;
        4)
            applyScreenResolution "1366x768"
            ;;
        5)
            applyScreenResolution "1920x1080"
            ;;
        *)
            selectScreenResolution
            ;;
    esac
}

function selectAdditionalPackages()
{
    cmd=(dialog --title "Other optional packages and features" 
        --backtitle "$SCRIPT_TITLE" 
        --checklist "Plese select to install:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "Lirc (IR remote support)" off
            2 "Hts tvheadend (live TV backend)" off
            3 "Oscam (live HDTV decryption tool)" off
            4 "Automatic upgrades (every 4 hours)" off)
            
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
                installAutomaticDistUpgrade
                ;;
        esac
    done
}

function selectVideoDriver()
{
    cmd=(dialog --backtitle "Select video driver (required)"
        --radiolist "Select your video chipset manufacturer:" 
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
	sudo apt-get -y autoremove > /dev/null 2>&1
	sudo apt-get -y autoclean > /dev/null 2>&1
	sudo apt-get -y clean > /dev/null 2>&1
	sudo rm -R "$TEMP_DIRECTORY" > /dev/null 2>&1
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
selectScreenResolution
reconfigureXServer
installPowerManagement
installAudio
selectXbmcTweaks
selectAdditionalPackages
cleanUp
rebootMachine
