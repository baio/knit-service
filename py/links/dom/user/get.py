__author__ = 'baio'
import pymongo as mongo
from config.config import config

def get(user_id):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    user = db.users.find_one({"_id": user_id})
    user["contribs"] = user["contribs"][::-1]
    for graph in user["graphs"]:
        contribs = graph["contribs"][::-1]#list(graph["contribs"])[::-1]
        graph["contribs"] = [filter(lambda x: x["ref"] == contrib, user["contribs"])[0] for contrib in contribs]

    return user
