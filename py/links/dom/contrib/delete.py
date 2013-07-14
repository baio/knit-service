__author__ = 'baio'

import pymongo as mongo
from  bson.objectid import ObjectId
from config.config import config
from dom.contrib.get_graphs import get_graphs

def delete(user_name, contrib_id):
    """delete contrib for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    graphs = get_graphs(user_name, contrib_id)
    db.users.update({"_id": user_name}, {"$pull" : {"contribs" : {"ref" : contrib_id}} })
    db.users.update({"_id": user_name, "graphs.contribs" : contrib_id}, {"$pull" : {"graphs.$.contribs" : contrib_id} })
    db.contribs.remove({"_id" : ObjectId(contrib_id)})

    return graphs

