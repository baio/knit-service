# -*- coding: utf-8 -*-
__author__ = 'baio'

import pymongo as mongo
from config.config import config

def put(user_name, graph_id, graph_name, contribs):
    """create new graph for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]

    db.users.update({"_id": user_name, "graphs.ref": graph_id}, {"$set": {"graphs.$.name": graph_name, "graphs.$.contribs":  contribs}})
    user = db.users.find_one({"_id": user_name, "graphs.ref": graph_id}, {"graphs.$" : 1, "contribs" : 1})
    graph = user["graphs"][0]
    contribs = list(graph["contribs"])
    graph["contribs"] = [filter(lambda x: x["ref"] == contrib, user["contribs"])[0] for contrib in contribs]

    return graph


