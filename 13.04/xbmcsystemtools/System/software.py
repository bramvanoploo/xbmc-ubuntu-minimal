import apt, apt_pkg, command, log
from inspect import stack

def updateSources():
    try:
        apt_cache = apt.cache.Cache()
        apt_cache.update()
        success = apt_cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())
        apt_cache.close()
        return success
    except AttributeError as e:
        log.error('AttributeError: ' +str(e), stack()[0][3])
        return False

def distUpgrade():
    apt_cache = apt.cache.Cache()
    apt_cache.update()
    apt_cache.open(None)
    apt_cache.upgrade(True)
    success = apt_cache.commit(apt.progress.TextFetchProgress(), apt.progress.InstallProgress())
    apt_cache.close()
    return success

def install(packageName):
    apt_pkg.init()
    apt_pkg.PkgSystemLock()
    apt_cache = apt.cache.Cache()
    pkg = apt_cache[packageName.strip()]

    if packageName.strip() in apt_cache:
        if pkg.isInstalled:
            apt_pkg.PkgSystemUnLock()
            log.info('Trying to install a package that is already installed (' +packageName.strip()+ ')', stack()[0][3])
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
                log.error('SystemError: ' +str(e), stack()[0][3])
                apt_cache.close()
                return False
    else:
        apt_cache.close()
        log.error('Unknown package selected (' +packageName.strip()+ ')', stack()[0][3])
        return False

def remove(packageName, purge = False):
    apt_pkg.init()
    apt_pkg.PkgSystemLock()
    apt_cache = apt.cache.Cache()
    pkg = apt_cache[packageName.strip()]

    if packageName.strip() in apt_cache:
        if not pkg.isInstalled:
            apt_pkg.PkgSystemUnLock()
            log.info('Trying to uninstall a package that is not installed (' +packageName.strip()+ ')', stack()[0][3])
            return False
        else:
            pkg.mark_delete(purge)
            try:
                apt_pkg.PkgSystemUnLock()
                result = apt_cache.commit()
                apt_cache.close()
                return result
            except SystemError as e:
                log.error('SystemError: ' +str(e), stack()[0][3])
                apt_cache.close()
                return False
    else:
        apt_cache.close()
        log.info('Unknown package selected (' +packageName.strip()+ ')', stack()[0][3])
        return False

def autoClean():
    return command.run('sudo apt-get -y autoclean', True)

def autoRemove():
    return command.run('sudo apt-get -y autoremove', True)

def search(packageName, installedPackes):
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