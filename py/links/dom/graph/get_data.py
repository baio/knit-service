__author__ = 'baio'
import pymongo as mongo
from config.config import config

def get(user_id, graph_id):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    user = db.users.find_one({"_id": user_id, "graphs.ref": graph_id}, {"graphs.$": 1, "contribs": 1 })
    ctrbs = []
    for contrib in user["graphs"][0]["contribs"]:
        user_contrib = filter(lambda x: x["ref"] == contrib, user["contribs"])[0]
        ctrbs.append(user_contrib)
    user["graphs"][0]["contribs"] = ctrbs
    return user["graphs"][0]
