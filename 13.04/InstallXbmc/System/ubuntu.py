import os, platform

def getArchitecture():
    if (os.name == "posix"):
        uname = platform.uname()
        return uname[4]
    else:
        return "0"
    
def getNumericVersion():
    if (os.name == "posix"):
        dist = platform.linux_distribution()
        return dist[1]
    else:
        return 0
    
def getVersion():
    if (os.name == "posix"):
        dist = platform.linux_distribution()
        return dist[0]+ ' ' +getNumericVersion()+ ' ' +dist[2]+ ' ' +getArchitecture()
    else:
        return "Unknown OS"
        
def getKernelVersion():
    if (os.name == "posix"):
        uname = platform.uname()
        return uname[2]
    else:
        return "0"
        

        
def runSystemUpdate():
    return 0
