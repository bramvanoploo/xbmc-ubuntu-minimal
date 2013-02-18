import socket
import os
import subprocess
import platform
import multiprocessing
import re

def getLocalIpAddress():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("google.com",80))
    return s.getsockname()[0]
    
def getArchitecture():
    if (os.name == "posix"):
        uname = platform.uname()
        return uname[4]
    else:
        return "0"
    
def getNumericUbuntuVersion():
    if (os.name == "posix"):
        dist = platform.linux_distribution()
        return dist[1]
    else:
        return 0
    
def getUbuntuVersion():
    if (os.name == "posix"):
        dist = platform.linux_distribution()
        return dist[0]+ ' ' +getNumericUbuntuVersion()+ ' ' +dist[2]+ ' ' +getArchitecture()+ ' (' +platform.version()+ ')'
    else:
        return "Unknown OS"
        
def getKernelVersion():
    if (os.name == "posix"):
        uname = platform.uname()
        return uname[2]
    else:
        return "0"
        
def getCurrentResolution():
    screen = runCmd("xrandr -q -d :0")
    width = screen.split()[7]
    height = screen.split()[9][:-1]
    return width+ ' x ' +height
    
def getMaximumResolution():
    screen = runCmd("xrandr -q -d :0")
    width = screen.split()[11]
    height = screen.split()[13]
    return width+ ' x ' +height
    
def getCpuType():
    cpuInfo = subprocess.check_output("cat /proc/cpuinfo", shell=True).strip()
    for line in cpuInfo.split("\n"):
        if "model name" in line:
            return re.sub( ".*model name.*:", "", line,1)
    
def getCpuCoreCount():
    return multiprocessing.cpu_count()
    
def getVga():
    return runCmd("lspci |grep VGA")
    
def getGpuManufacturer():
    vga = getVga()
    manufacturer = vga.split()[4]
    return manufacturer
    
def getGpuType():
    vga = getVga()
    version = vga.split("[")[1].replace("]", "")
    return version
    
def getTotalRam():
    ramInfo = subprocess.check_output("cat /proc/meminfo", shell=True).strip()
    for line in ramInfo.split("\n"):
        if "MemTotal" in line:
            return (int(re.sub( "MemTotal: ", "", line , 1).replace(" kB", "")) / 1024)
            
def getFreeRam():
    ramInfo = subprocess.check_output("cat /proc/meminfo", shell=True).strip()
    for line in ramInfo.split("\n"):
        if "MemFree" in line:
            return (int(re.sub( "MemFree: ", "", line , 1).replace(" kB", "")) / 1024)
        
def runSystemUpdate():
    return 0
        
def runCmd(cmd):
    p = subprocess.Popen(cmd,
        shell=True, 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE, 
        close_fds=True)
    result = p.stdout.readlines()
    #s = result[0].split()[2]
    return result[0]
