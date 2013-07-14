__author__ = 'baio'

import pymongo as mongo
from  bson.objectid import ObjectId
from config.config import config

def delete(user_name, graph_id):
    """delete contrib for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    db.users.update({"_id": user_name}, {"$pull" : {"graphs" : {"ref" : graph_id}} })
    db.graphs.meta.remove({"_id" : ObjectId(graph_id)})

