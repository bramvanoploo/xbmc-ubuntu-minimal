import config, command, logging, os, time
from datetime import datetime

def backupConfig():
    fileName = datetime.now()+ '_xbmc_backup.tar.bz2'
    backupPath = config.xbmc_backups_dir+fileName
    if command.run('tar -cjf ' +backupPath+ ' ' +config.xbmc_home_dir, True):
        return True
    return False

def getExistingBackupUrlPaths():
    files = reversed(sorted(os.listdir(config.xbmc_backups_dir)))
    urlPaths = []
    for file in files:
        if os.path.isfile(config.xbmc_backups_dir+file):
            filenameParts = file.split('_')
            timestamp = filenameParts[0]
            entry = {
                'path' : config.xbmc_backups_url_path+file,
                'name' : file,
                'timestamp' : timestamp,
                'hr_time' : datetime.fromtimestamp(int(timestamp))
            }
            urlPaths.append(entry)
    return urlPaths