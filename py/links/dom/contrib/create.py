__author__ = 'baio'

import pymongo as mongo
import datetime as dt
from config.config import config


def create(user_name, contrib_name, graph_ref):
    """create new contrib for the user"""
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    now = dt.datetime.now()

    ref = db.contribs_v2.insert({})
    schemes = ["person-person.ru", "person-org.ru", "org-org.ru"]
    contrib = {"name": contrib_name, "date": now, "ref": str(ref), "schemes" : schemes}
    db.users.update({"_id": user_name}, {"$push" : { "contribs" :  contrib}})
    if graph_ref:
        db.users.update({"_id": user_name, "graphs.ref": graph_ref}, {"$push" : { "graphs.$.contribs" :  str(ref)}})

    return contrib


