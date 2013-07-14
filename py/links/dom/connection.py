__author__ = 'baio'
import pymongo as mongo
from config.config import config

_db = None

def get_db():
    global _db
    if _db == None:
        client = mongo.MongoClient(config["MONGO_URI"])
        _db = client[config["MONGO_DB"]]
    return _db


#test