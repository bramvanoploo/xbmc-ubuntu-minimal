import os, platform, config, shutil, apt, apt.progress
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

def deleteFile(filePath):
    if os.path.isFile(filePath):
        os.remove(filePath)
        return True
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
        with open(filePath, "a") as file:
            file.write(content)
            return True
    return False

#Package management
def aptUpdate():
    cache = apt.Cache()
    cache.update()
    cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())

def aptUpgrade():
    cache = apt.Cache()
    cache.update()
    cache.open(None)
    cache.upgrade(True)
    cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())

def aptInstall(packageName):
    cache = apt.Cache()
    if not packageName in cache or cache[packageName].is_installed:
        return False
    package = cache[packageName]
    package.markInstall()
    cache.commit()

def isPackageInstalled(packageName):
    cache = apt.Cache()
    cache.open()
    if packageName in cache and cache[packageName].is_installed:
        return True
    return False

def addPpa(ppaName):
    sp = SoftwareProperties()
    sp.add_source_from_line(ppaName)
    sp.sourceslist.save()
    aptUpgrade()