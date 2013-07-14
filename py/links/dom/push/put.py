__author__ = 'baio'

__author__ = 'baio'

import pymongo as mongo
from config.config import config

def put(user_name, graph_ref, push_user_name, status):
    """create new contrib for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    db.users.update({"_id": user_name, "graphs.ref": graph_ref},
                    {"$set": {"graphs.$.pushes":  {"user": push_user_name, "status": status}}})

    if (status == "accept"):
        pass
    elif (status == "reject"):
        db.users.update({"_id": user_name},
                        {"$pull": {"graphs":  {"ref": graph_ref, "src_user": user_name}}})


