import os, shutil, log
from inspect import stack

def createBackupFile(filePath):
    shutil.copy(filePath, filePath+ ".backup")

def restoreBackupFile(filePath):
    if os.path.isFile(filePath+ ".backup"):
        deleteFile(filePath)
        shutil.copy(filePath+ ".backup", filePath)
        return True
    return False

def delete(path):
    if os.path.exists(path.strip()):
        try:
            os.remove(path.strip())
            return True
        except:
            pass
    return False

def deleteFile(filePath):
    if os.path.isfile(filePath.strip()):
        try:
            os.remove(filePath.strip())
            return True
        except:
            pass
    return False

def deleteDirectory(directoryPath):
    if os.path.isdir(directoryPath.strip()):
        try:
            shutil.rmtree(directoryPath.strip())
            return True
        except:
            pass
    return False

def createFile(filePath, backupExisting = True, deleteExisting = False):
    if deleteExisting:
        deleteFile(filePath)
    if backupExisting:
        backupFile(filePath)
    open(filePath, 'w').close()
    return True

def createDirectory(directoryPath):
    if not os.path.exists(directoryPath):
        os.makedirs(directoryPath)
        return True
    return False

def getDirectorySize(startPath):
    if not os.path.isdir(startPath.strip()):
        return False
    totalSize = 0
    readableSize = ''
    for dirPath, dirNames, fileNames in os.walk(startPath.strip()):
        for f in fileNames:
            fp = os.path.join(dirPath, f)
            totalSize += os.path.getsize(fp)
    return totalSize

def appendToFile(filePath, content):
    if os.path.isFile(filePath):
        backupFile(filePath)
    else:
        createFile(filePath)
    with open(filePath, "a") as file:
        file.write(content)
        return True
    return False

def move(source, destination):
    shutil.move(source, destination)