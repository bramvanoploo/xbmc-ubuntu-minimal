import shelve

databaseFile = 'global.db'

def set(category, key, value):
    s = shelve.open(databaseFile, writeback = True)
    try:
        if not categoryExists(category):
            s[category] = {}
            print s[category]
        s[category][key] = value
        print s[category]
    finally:
        s.close()

def get(category, key):
    s = shelve.open(databaseFile)
    value = ''
    try:
        value = s[category][key]
    finally:
        s.close()
    return value

def categoryExists(category):
    s = shelve.open(databaseFile, writeback = True)
    if s.has_key(category):
        return True
    return False

def keyExists(category, key):
    s = shelve.open(databaseFile, writeback = True)
    if s.has_key(category) and s[category].has_key(key):
        return True
    return False