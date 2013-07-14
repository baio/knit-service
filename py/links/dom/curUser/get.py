__author__ = 'baio'
import pymongo as mongo
from config.config import config


def _get_popular_refs():
    return ["518b989739ed9714289d0bc1"]

def _get_popular(db):
    refs = _get_popular_refs()
    users = db.users.find({"graphs.ref" : {"$in" : refs}},
                            {"name": 1, "graphs.ref" : 1, "graphs.name" : 1}).limit(5)
    return map(lambda x: {"name": x["graphs"][0]["name"], "ref": x["graphs"][0]["ref"], "user": x["_id"], "userName": x["name"]}, users)

def get(user_id, user_name):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    if user_id:
        user = db.users.find_one({"_id": user_id})
        if not user:
            user = {"_id": user_id, "name": user_name, "contribs": [], "graphs": []}
            db.users.insert(user)
        curUser = {"_id": user["_id"], "name": user["name"]}
        curUser["graphs"] = map(lambda x: {"name": x["name"], "ref": x["ref"],
                                           "user" : user["_id"], "userName" : user["name"]}, user["graphs"])
        curUser["popular"] = _get_popular(db)
    else:
        curUser = {"_id": None, "contribs" : [], "popular" : _get_popular(db)}

    return curUser

