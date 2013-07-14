__author__ = 'baio'

import pymongo as mongo
from config.config import config

def update(user_name, contrib_ref, name):
    """update contrib name, url"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    db.users.update({"_id": user_name, "contribs.ref" : contrib_ref},
                   {"$set" : {"contribs.$.name" :  name}})
    user = db.users.find_one({"_id": user_name, "contribs.ref": contrib_ref}, {"contribs.$" : 1})

    return user["contribs"][0]
