import urllib2, re, config, ubuntu, os, command
from BeautifulSoup import BeautifulSoup

def getFirstUrl(line):
    urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', line)
    if len(urls) > 0:
        return urls[0]
    else:
        return ''

def get():
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

def install(repositoryUrl, repositoryFileName = 'addon_repo.zip'):
    repoZipFilePath = '/tmp/'+repositoryFileName
    ubuntu.delete(repoZipFilePath)
    try:
        f = urllib2.urlopen(repositoryUrl)
    except:
        return False
    data = f.read()
    with open(repoZipFilePath, 'wb') as code:
        code.write(data)
    if not os.path.exists(repoZipFilePath):
        return False
    command.run('unzip ' +repoZipFilePath+ ' -d ' +config.xbmc_addons_dir)
    return command.run('sudo chown -R ' +config.xbmc_user+ ':' +config.xbmc_user+ ' ' +config.xbmc_addons_dir)





