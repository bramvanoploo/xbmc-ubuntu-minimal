import config, command, logging, os, time, ubuntu
from datetime import datetime

def backupConfig():
    fileName = str(int(time.time()))+'_xbmc_backup.tar.gz'
    backupPath = config.xbmc_backups_dir+fileName
    if command.run('tar -czf "' +backupPath+ '" -C "' +config.home_directory+ '" ".xbmc"', True):
        return True
    return False

def restoreBackup(backupFile):
    filePath = config.xbmc_backups_dir+backupFile
    ubuntu.deleteDirectory(config.xbmc_home_dir)
    if command.run('tar -zxf "' +filePath+ '" -C "' +config.home_directory, True):
        return True
    return False

def getExistingBackupUrlPaths():
    files = reversed(sorted(os.listdir(config.xbmc_backups_dir)))
    urlPaths = []
    for file in files:
        if os.path.isfile(config.xbmc_backups_dir+file):
            filenameParts = file.split('_')
            timestamp = filenameParts[0]

            try:
                hr_time = datetime.fromtimestamp(int(timestamp))
            except:
                timestamp = 0
                hr_time = file
                pass

            fileSize = os.stat(config.xbmc_backups_dir+file).st_size
            entry = {
                'path' : config.xbmc_backups_url_path+file,
                'name' : file,
                'timestamp' : timestamp,
                'hr_time' : hr_time,
                'size' : fileSize,
                'readable_size' : ubuntu.getRedableSize(fileSize)
            }
            urlPaths.append(entry)
    return urlPaths

def deleteBackup(backupFileName):
    return ubuntu.deleteFile(config.xbmc_backups_dir+backupFileName)