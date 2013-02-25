import os, platform, config, network, shutil, apt, apt_pkg, apt.progress, config, command, logging
from softwareproperties.SoftwareProperties import SoftwareProperties

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

## File and directory management
def backupFile(filePath):
    shutil.copy(filePath, filePath+ ".backup")

def restoreBackupFile(filePath):
    if os.path.isFile(filePath+ ".backup"):
        deleteFile(filePath)
        shutil.copy(filePath+ ".backup", filePath)
        return True
    return False

def delete(path):
    if os.path.exists(path):
        try:
            os.remove(path)
            return True
        except:
            pass
    return False

def deleteFile(filePath):
    if os.path.isFile(filePath):
        try:
            os.remove(filePath)
            return True
        except:
            pass
    return False

def deleteDirectory(directoryPath):
    if os.path.exists(directoryPath):
        shutil.rmtree(directoryPath)
        return True
    return False

def createFile(filePath, backupExisting = True, deleteExisting = False):
    if deleteExisting:
        deleteFile(filePath)
    if backupExisting:
        backupFile(filePath)
    open(filePath, 'w').close()
    return True

def createDirectory(directoryPath):
    if not os.path.exists(directoryPath):
        os.makedirs(directoryPath)
        return True
    return False

def appendToFile(filePath, content):
    if os.path.isFile(filePath):
        backupFile(filePath)
    else:
        createFile(filePath)
    with open(filePath, "a") as file:
        file.write(content)
        return True
    return False

def move(source, destination):
    shutil.move(source, destination)

#Package management
def aptUpdate():
    apt_cache = apt.cache.Cache()
    apt_cache.update()
    success = apt_cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())
    apt_cache.close()
    return success

def aptDistUpgrade():
    apt_cache = apt.cache.Cache()
    apt_cache.update()
    apt_cache.open(None)
    apt_cache.upgrade(True)
    success = apt_cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())
    apt_cache.close()
    return success

def aptInstall(packageName):
    apt_pkg.init()
    apt_pkg.PkgSystemLock()
    apt_cache = apt.cache.Cache()
    pkg = apt_cache[packageName.strip()]

    if packageName.strip() in apt_cache:
        if pkg.isInstalled:
            apt_pkg.PkgSystemUnLock()
            logging.error('Trying to install a package that is already installed (%s)', packageName.strip())
            apt_cache.close()
            return False
        else:
            pkg.mark_install()
            try:
                apt_pkg.PkgSystemUnLock()
                result = apt_cache.commit()
                apt_cache.close()
                return result
            except SystemError as e:
                logging.exception(e)
                apt_cache.close()
                return False
    else:
        apt_cache.close()
        loggin.error('Unknown package selected (%s)', packageName.strip())
        return False

def aptRemove(packageName, purge = False):
    apt_pkg.init()
    apt_pkg.PkgSystemLock()
    apt_cache = apt.cache.Cache()
    pkg = apt_cache[packageName.strip()]

    if packageName.strip() in apt_cache:
        if not pkg.isInstalled:
            apt_pkg.PkgSystemUnLock()
            logging.error('Trying to uninstall a package that is not installed (%s)', packageName.strip())
            return False
        else:
            pkg.mark_delete(purge)
            try:
                apt_pkg.PkgSystemUnLock()
                result = apt_cache.commit()
                apt_cache.close()
                return result
            except SystemError as e:
                logging.exception(e)
                apt_cache.close()
                return False
    else:
        apt_cache.close()
        loggin.error('Unknown package selected (%s)', packageName.strip())
        return False

def aptAutoClean():
    return command.run('sudo apt-get -y autoclean', True)

def aptAutoRemove():
    return command.run('sudo apt-get -y autoremove', True)

def aptSearch(packageName, installedPackes):
    apt_cache = apt.cache.Cache()
    packages = apt_cache.keys()
    if installedPackes:
        result = [value for value in packages if apt_cache[value].isInstalled and packageName.strip() in value]
    else:
        result = [value for value in packages if not apt_cache[value].isInstalled and packageName.strip() in value]
    apt_cache.close()

    return sorted(result)

def isPackageInstalled(packageName):
    apt_cache = apt.cache.Cache()
    apt_cache.open()
    if packageName.strip() in cache and cache[packageName.strip()].is_installed:
        apt_cache.close()
        return True
    apt_cache.close()

    return False

def packageExists(packageName):
    apt_cache = apt.cache.Cache()
    apt_cache.open()
    if packageName.strip() in cache:
        apt_cache.close()
        return True
    apt_cache.close()

    return False

def addPpa(ppaName):
    if ppaName.strip().startswith('ppa:') or ppaName.strip().startswith('deb http://ppa.launchpad.net/') or ppaName.strip().startswith('deb-src http://ppa.launchpad.net/'):
        success = command.run('sudo add-apt-repository -y "' +ppaName.strip()+ '"', True)
        aptUpdate()
        return True #Always return True because somehow add-apt-repository command always throws an error, even wen successfull
    else:
        return False

# This method always returns true but never succeeds
def removePpa(ppaName):
    if not ppaName.strip().startswith('ppa:') or not '/' in ppaName:
        return False
    success = command.run('sudo add-apt-repository -y -r "' +ppaName.strip()+ '"', True)
    aptUpdate()
    return success

def purgePpa(ppaName):
    if not ppaName.strip().startswith('ppa:') or '/' not in ppaName:
        return False
    success = command.run('sudo ppa-purge -y '+ppaName.strip(), True)
    aptUpdate()
    return success

def getActivePpas(keyWord):
    ppasText = command.run('grep -hi "^deb.*launchpad" /etc/apt/sources.list /etc/apt/sources.list.d/*')
    ppas = []
    ppaLines = ppasText.split('\n')
    for line in ppaLines:
        ppaParts = line.split(' ')
        if len(ppaParts) == 4:
            ppaUrlParts = ppaParts[1].split('/')
            ppaUserName = ppaUrlParts[-3]
            ppaName = ppaUrlParts[-2]
            ppas.append('ppa:'+ppaUserName+'/'+ppaName)
    sortedPpas = sorted(list(set(ppas)))

    if keyWord.strip() == '':
        return sortedPpas
    else:
        filteredPpas = []
        for entry in sortedPpas:
            if keyWord in entry:
                filteredPpas.append(entry)
        return filteredPpas

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