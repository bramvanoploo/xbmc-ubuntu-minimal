import config, command, os, time, urllib2, helper, log, fileSystem
from datetime import datetime
from BeautifulSoup import BeautifulSoup
from inspect import stack

def backupConfig():
    fileName = str(int(time.time()))+'_xbmc_backup.tar.gz'
    backupPath = config.xbmc_backups_dir+fileName
    if command.run('tar -czf "' +backupPath+ '" -C "' +config.home_directory+ '" ".xbmc"', True):
        return True
    return False

def restoreBackup(backupFile):
    filePath = config.xbmc_backups_dir+backupFile
    fileSystem.deleteDirectory(config.xbmc_home_dir)
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
                'readable_size' : helper.getReadableSize(fileSize)
            }
            urlPaths.append(entry)
    return urlPaths

def deleteBackup(backupFileName):
    return fileSystem.deleteFile(config.xbmc_backups_dir+backupFileName)

def getInstallableRepositories():
    repositories = []
    soup = BeautifulSoup(urllib2.urlopen(config.xbmc_repositories_url).read())
    table = soup.find('table')
    rows = table.findAll('tr')
    for row in rows:
        cols = row.findAll('td')

        if len(cols) is 5:
            repoWebsiteAnchor = cols[0].find('a', href=True)
            if repoWebsiteAnchor:
                repoName = str(repoWebsiteAnchor.string).replace("\n", "")
                repoWebsiteUrl = repoWebsiteAnchor['href']
            else:
                repoName = str(cols[0].string).replace("\n", "")
                repoWebsiteUrl = ''
            repoDescription = str(cols[1].string).replace("\n", "")
            repoOwner = str(cols[2].string).replace("\n", "")
            repoFileAnchor = cols[3].find('a', href=True)
            if repoFileAnchor:
                repoFileUrl = repoFileAnchor['href']
                repoFileName = str(repoFileAnchor.string).replace("\n", "")
            else:
                repoFileUrl = ''
                repoFileName = ''
            repoIconAnchor = cols[4].find('a', href=True)
            if repoIconAnchor:
                repoIconUrl = repoIconAnchor['href']
            else:
                repoIconUrl = ''
            entry = {
                'name' : repoName,
                'website_url' : repoWebsiteUrl,
                'description' : repoDescription,
                'owner' : repoOwner.replace("\n", ""),
                'download_url' : repoFileUrl,
                'file_name' : repoFileName,
                'icon_url' : repoIconUrl
            }
            repositories.append(entry)
    return repositories

def installRepository(repositoryUrl, repositoryFileName = 'addon_repo.zip'):
    repoZipFilePath = '/tmp/'+repositoryFileName.strip()
    fileSystem.delete(repoZipFilePath)
    try:
        f = urllib2.urlopen(repositoryUrl.strip())
    except:
        log.error('Repository ' +repositoryUrl+ ' could not be downloaded',  stack()[0][3])
        return False
    data = f.read()
    with open(repoZipFilePath, 'wb') as code:
        code.write(data)
    if not os.path.exists(repoZipFilePath):
        log.error('Repository file' +repoZipFilePath+ ' does not exist',  stack()[0][3])
        return False
    if not command.run('unzip -o ' +repoZipFilePath+ ' -d ' +config.xbmc_addons_dir):
        log.error('Repository file' +repoZipFilePath+ ' could not be extracted',  stack()[0][3])
        return False
    return command.run('sudo chown -R ' +config.xbmc_user+ ':' +config.xbmc_user+ ' ' +config.xbmc_addons_dir)