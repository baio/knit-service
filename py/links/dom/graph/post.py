# -*- coding: utf-8 -*-
__author__ = 'baio'

import pymongo as mongo
from config.config import config
import datetime as dt
from  bson.objectid import ObjectId

def post(user_name, graph_name, contribs):
    """create new graph for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    now = dt.datetime.now()

    graph = {"name": graph_name, "date": now, "contribs": contribs, "ref": str(ObjectId())}

    db.users.update({"_id": user_name}, {"$addToSet": {"graphs":  graph}})

    return graph


