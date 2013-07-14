__author__ = 'baio'

import pymongo as mongo
import datetime as dt
from config.config import config


def update_contrib_from_json(user_name, data):

    now = dt.datetime.now()

    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links

    contrib_name = data["name"]
    contrib_url = data["url"]

    user = db.user.find_one({"_id": user_name}, {"_id" : 0, "contribs" : { "$elemMatch" : {"name" : contrib_name}}})

    if user is None:
        user = {"_id" : user_name }

    if "contribs" not in user:
        contrib = {"name": contrib_name, "date": now, "data": []}
    else:
        contrib = user["contribs"][0]

    data = contrib["data"]

    def _map_item(item):
        tags = filter(lambda x: x is not None, [item.get("family_rel", None),
                item.get("prof_rel", None),
                item.get("private_rel", None)])
        return {"name_1" : item["name_1"], "name_2" : item["name_2"], "tags" : tags, "url" : contrib_url}
    data = map(_map_item, data)

    """find and replace items in data, or create new"""
    for d in data:

        """ordering names"""
        if d["name_1"] > d["name_2"]:
            dd = d["name_1"]
            d["name_1"] = d["name_2"]
            d["name_2"] = dd

        """find same names in collection"""
        i = filter(lambda x: x["name_1"] == d["name_1"] and x["name_2"] == d["name_2"], data)

        if len(i) > 0:
            data.remove(i[0])

        data.append(d)

    contrib["data"] = data

    #upsert
    if "_id" in user:
        user["contribs"] = [contrib]
        db.user.insert(user)
    else:
        if "contribs" in user:
            """modifying old contrib"""
            db.user.update({"_id": user_name, "contribs.name" : contrib_name}, {"$set" :  {"contribs.$" : contrib}})
        else:
            db.user.update({"_id": user_name}, {"$push" : { "contribs" :  contrib}})

    return []
