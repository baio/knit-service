__author__ = 'baio'

import pymongo as mongo
from config.config import config


def post(user_name, graph_ref, push_user_name, push_graph_ref):
    """create new contrib for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    db.users.update({"_id": user_name, "graphs.ref": graph_ref},
                    {"$addToSet": {"graphs.$.pushes":  {"dest_user": push_user_name, "status": "request"}}})

    db.users.update({"_id": push_user_name, "graphs.ref": push_graph_ref},
                    {"$addToSet": {"graphs.$.requests":  {"ref": graph_ref, "src_user": user_name, "status": "request"}}})
