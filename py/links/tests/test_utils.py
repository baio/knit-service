__author__ = 'baio'

import pymongo as mongo
from config.config import config

class TestUtils:

    def __init__(self):
        client = mongo.MongoClient(config["MONGO_URI"])
        self.db = client[config["MONGO_DB"]]

    def remove_collections(self):
        self.db.users.remove()
        self.db.contribs.remove()

    def create_def_user(self):
        self.db.users.insert({"_id" : "baio"})
