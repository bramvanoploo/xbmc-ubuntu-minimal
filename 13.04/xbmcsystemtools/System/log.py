import config, datetime

def debug(message, method = ''):
    if config.debug:
        debugLog = open(config.debug_log, 'a')
        debugLog.write(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+ ' : ' +method+ ' : ' +message+ '\n')
        debugLog.close()

def error(message, method = ''):
    errorLog = open(config.error_log, 'a')
    errorLog.write(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+ ' : ' +method+ ' : ' +message+ '\n')
    errorLog.close()

def info(message, method = ''):
    infoLog = open(config.info_log, 'a')
    infoLog.write(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+ ' : ' +method+ ' : ' +message+ '\n')
    infoLog.close()