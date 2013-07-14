__author__ = 'baio'

from converters.line2bucket import parse_lines
import pymongo as mongo
import datetime as dt
from config.config import config

def update_contrib_from_lines(user_name, contrib_name, lines):

    bucks, errs = parse_lines(lines)

    if len(errs) > 0: return errs

    now = dt.datetime.now()

    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links

    user = db.user.find_one({"_id": user_name}, {"_id" : 0, "contribs" : { "$elemMatch" : {"name" : contrib_name}}})

    if user is None:
        user = {"_id" : user_name }

    if "contribs" not in user:
        contrib = {"name": contrib_name, "date": now, "data": []}
    else:
        contrib = user["contribs"][0]

    data = map(lambda x: {"name_1" : x[0], "name_2" : x[1], "tags" : x[2], "url" : x[3]}, bucks)

    """find and replace items in data, or create new"""
    for d in data:

        """ordering names"""
        if d["name_1"] > d["name_2"]:
            dd = d["name_1"]
            d["name_1"] = d["name_2"]
            d["name_2"] = dd

        """find same names in collection"""
        i = filter(lambda x: x["name_1"] == d["name_1"] and x["name_2"] == d["name_2"], contrib["data"])
        if len(i) > 0:
            contrib["data"].remove(i[0])

        contrib["data"].append(d)

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