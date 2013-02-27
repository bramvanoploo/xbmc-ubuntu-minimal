import os, platform, config, network, config, command

#System information
def getArchitecture():
    if os.name == "posix":
        uname = platform.uname()
        return uname[4]
    else:
        return "Unknown architecture"

def getNumericVersion():
    if os.name == "posix":
        dist = platform.linux_distribution()
        return dist[1]
    else:
        return 0.0

def getVersion():
    if os.name == "posix":
        dist = platform.linux_distribution()
        return dist[0]+ ' ' +getNumericVersion()+ ' ' +dist[2]+ ' ' +getArchitecture()
    else:
        return "Unknown operating system version"

def getKernelVersion():
    if os.name == "posix":
        uname = platform.uname()
        return uname[2]
    else:
        return "Unknown kernel version"

# Power control
def shutdown():
    return command.run('sudo shutdown now -h -q', True)

def reboot():
    return command.run('sudo reboot now -q', True)

# Installation methods
def createTempDirectory():
    createDirectory(temp_directory)

def fixLocaleBug():
    restoreBackupFile(config.environment_file)
    appendToFile(config.environment_file, 'LC_MESSAGES="C"')
    appendToFile(config.environment_file, 'LC_ALL="en_US.UTF-8"')

def fixUsbAutomount():
    rulesFileUrl = github_download_url+'media-by-label-auto-mount.rules'
    tempRulesFile = temp_directory+'media-by-label-auto-mount.rules'
    restoreBackupFile(config.modules_file)
    appendToFile(config.modules_file, 'usb-storage')
    network.download(rulesFileUrl, tempRulesFile)
    if os.path.isfile(tempRulesFile) and move(tempRulesFile, config.automount_rules_file):
        deletFile(tempRulesFile)

def applyXbmcNiceLevelPermissions():
    createFile(config.system_limits_file)
    restoreBackupFile(config.system_limits_file)
    appendToFile(config.system_limits_file, config.xbmc_user+"             -       nice            -1")