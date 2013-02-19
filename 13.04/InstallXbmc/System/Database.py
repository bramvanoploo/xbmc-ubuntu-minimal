import shelve

class Database:
    __dbFile = None

    def __init__(self, databaseFile=None):
        self.__dbFile = databaseFile

    def set(self, category, key, value):
        s = shelve.open(self.__dbFile, writeback = True)
        try:
            if not self.categoryExists(category):
                s[category] = {}
                print s[category]
            s[category][key] = value
            print s[category]
        finally:
            s.close()

    def get(self, category, key):
        s = shelve.open(self.__dbFile)
        value = ''
        try:
            value = s[category][key]
        finally:
            s.close()
        return value

    def categoryExists(self, category):
        s = shelve.open(self.__dbFile, writeback = True)
        if s.has_key(category):
            return True
        return False

    def keyExists(self, category, key):
        s = shelve.open(self.__dbFile, writeback = True)
        if s.has_key(category) and s[category].has_key(key):
            return True
        return False