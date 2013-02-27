import log, command, software
#from softwareproperties.SoftwareProperties import SoftwareProperties

def add(ppaName):
    if ppaName.strip().startswith('ppa:') or ppaName.strip().startswith('deb http://ppa.launchpad.net/') or ppaName.strip().startswith('deb-src http://ppa.launchpad.net/'):
        success = command.run('sudo add-apt-repository -y "' +ppaName.strip()+ '"', True)
        software.updateSources()
        return True #Always return True because somehow add-apt-repository command always throws an error, even wen successfull
    else:
        return False

def remove(ppaName):
    if not ppaName.strip().startswith('ppa:') or not '/' in ppaName:
        return False
    success = command.run('sudo add-apt-repository -y -r "' +ppaName.strip()+ '"', True)
    software.updateSources()
    return success

def purge(ppaName):
    if not ppaName.strip().startswith('ppa:') or '/' not in ppaName:
        return False
    success = command.run('sudo ppa-purge -y '+ppaName.strip(), True)
    software.updateSources()
    return success

def getActive(keyWord):
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
