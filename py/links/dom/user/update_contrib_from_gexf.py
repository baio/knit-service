__author__ = 'baio'
from dom.gexf import get_nodes_from_gexf
import pymongo as mongo
from config.config import config

def update_contrib_from_gexf(user_name, graph_name, gexf_xml):
    gexf_nodes = list(get_nodes_from_gexf(gexf_xml))

    if len(gexf_nodes) == 0:  return

    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links

    user = db.user.find_one({"_id": user_name}, {"_id" : 0, "graphs" : { "$elemMatch" : {"name" : graph_name}}})

    changed = False
    for node in user["graphs"][0]["nodes"]:
        n = filter(lambda x: node["_id"] == x[0], gexf_nodes)
        if len(n) > 0 and len(n[0][1]) > 0:
            node["pos"] = n[0][1]
            changed = True

    if changed:
        db.user.update({"_id": user_name, "graphs.name" : graph_name}, {"$set" :  {"graphs.$" : user["graphs"][0]}})

