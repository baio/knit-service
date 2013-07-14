__author__ = 'baio'
import pymongo as mongo
from config.config import config
from converters.tag2rel_type import tag2rel_type

def _prepare_data_item(item):
    for tag in item["tags"]:
        rel_type = tag2rel_type(tag)
        item[rel_type] = tag
    del item["tags"]
    del item["url"]

def get_contrib(user_name, contrib_name):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    user = db.user.find_one({"_id": user_name}, {"contribs" : { "$elemMatch" : {"name" : contrib_name}}})
    user["contribs"][0]["url"] = user["contribs"][0]["data"][0]["url"]
    for i in user["contribs"][0]["data"]:
        _prepare_data_item(i)
    return user["contribs"][0]
