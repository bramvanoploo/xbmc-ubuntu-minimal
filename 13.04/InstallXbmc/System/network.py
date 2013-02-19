import socket, urllib

def getLocalIpAddress():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("google.com",80))
    return s.getsockname()[0]

def download(fileUrl, destinationFile):
    urllib.urlretrieve (fileUrl, destinationFile)