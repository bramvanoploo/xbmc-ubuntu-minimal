import re

def getFirstUrl(line):
    urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', line)
    return urls[0] if len(urls) > 0 else ''

def getReadableSize(bytesSize):
    sizeKb = bytesSize / (1024.0 ** 1)
    sizeMb = bytesSize / (1024.0 ** 2)
    sizeGb = bytesSize / (1024.0 ** 3)
    if sizeKb < 1024:
        readableSize = '%.2f KB' % sizeKb
    elif sizeMb < 1024:
        readableSize = '%.2f MB' % sizeMb
    else:
        readableSize = '%.2f GB' % sizeGb
    return readableSize