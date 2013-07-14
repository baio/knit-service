__author__ = 'baio'

import pymongo as mongo
import datetime as dt
from config.config import config
import itertools

def store(bucks):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    now = dt.datetime.now()
    data = map(lambda x: {"name_1" : x[0], "name_2" : x[1], "tags" : x[2], "url" : x[3]}, bucks)
    ctb = {
        "_id": "{}_{}".format("baio", now.strftime("%Y%m%dT%M%S")),
        "user" : "baio",
        "data": data,
        "date": now
    }
    db.contribs.save(ctb)

def contribs2edges():
    """
    function to convert contribs collection items to edges ones
    edge doc {_id, name_1, name_2, tags [{name, urls[]}]}
    ===========================================================
    if src in srcs then skip
    if name_1 and name_2 not found then insert new doc
    if tag.name not found then insert new tag
    if tag.url not found then insert new url
    """
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    db.edges.remove()
    edges = dict()
    for contrib in db.contribs.find():
        for item in contrib["data"]:
            id = u"{} {}".format(item["name_1"], item["name_2"]).replace(" ", "_")
            edge = edges.get(id) #db.edges.find_one({"_id" : id}))
            if not edge:
                edge = {"_id" : id, "name_1" : item["name_1"], "name_2" : item["name_2"], "tags" : []}
            for tag in item["tags"]:
                edge_tag = filter(lambda x: x["name"] == tag, edge["tags"])
                if len(edge_tag):
                    edge_tag = edge_tag[0]
                else:
                    edge_tag = {"name" : tag, "urls" : []}
                    edge["tags"].append(edge_tag)
                if item["url"] not in edge_tag["urls"]:
                    edge_tag["urls"].append(item["url"])
            if id not in edges:
                edges[id] = edge
    db.edges.insert(edges.values())

def get_edges():
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    for edge in db.edges.find():
        yield (edge["name_1"], edge["name_2"], list(x["name"] for x in edge["tags"]),
                   "|".join(set(sum([x["urls"] for x in edge["tags"]],[]))))

def get_nodes():
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    for node in db.nodes.find():
        yield (node["_id"], node["pos"])

def store_nodes(nodes):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    for node in nodes:
        db.nodes.save({"_id" : node[0], "pos" : node[1]})