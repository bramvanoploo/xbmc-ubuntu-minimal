import command, subprocess, multiprocessing, re

def getCurrentResolution():
    screen = command.run("xrandr -q -d :0")
    width = screen.split()[7]
    height = screen.split()[9][:-1]
    return width+ ' x ' +height
    
def getMaximumResolution():
    screen = command.run("xrandr -q -d :0")
    width = screen.split()[11]
    height = screen.split()[13]
    return width+ ' x ' +height
    
def getCpuType():
    cpuInfo = subprocess.check_output("cat /proc/cpuinfo", shell=True).strip()
    for line in cpuInfo.split("\n"):
        if "model name" in line:
            return re.sub( ".*model name.*:", "", line,1)
          
def getCpuLoad():
    return command.run("ps aux|awk 'NR > 0 { s +=$3 }; END {print s}'")
    
def getCpuCoreCount():
    return multiprocessing.cpu_count()
    
def getVga():
    return command.run("lspci |grep VGA")
    
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
            
def getRamInUse():
    return (int(getTotalRam()) - int(getFreeRam()))
