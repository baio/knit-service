# -*- coding: utf-8 -*-
__author__ = 'baio'

import pymongo as mongo
from config.config import config
from  bson.objectid import ObjectId

def _get_default_contrib_id():
    return "518b989739ed9714289d0bc1"
def _get_default_graph():
    return "twitter@baio1980", "518b989739ed9714289d0bc1"

def get(user_name, graph_id):
    orig_user_id = user_name
    if not user_name and not graph_id:
        user_name, graph_id = _get_default_graph()
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    user = db.users.find_one({"_id": user_name})
    if user_name and not graph_id:
        if user and "graphs" in user and len(user["graphs"]) > 0:
            user_graph = user["graphs"][0]
            graph_id = user_graph["ref"]
        else:
            user_name, graph_id = _get_default_graph()
            user = db.users.find_one({"_id": user_name})
            user_graph = filter(lambda x: x["ref"] == graph_id, user["graphs"])[0]
    else:
        if not user:
            user = db.users.find_one({"graphs.ref": graph_id})
        user_graph = filter(lambda x: x["ref"] == graph_id, user["graphs"])[0]
    is_yours = user["_id"] == orig_user_id
    graph_name = user_graph["name"]
    graph_meta = db.graphs.meta.find_one({"_id" : ObjectId(graph_id)})
    nodes_meta = graph_meta["nodes"] if graph_meta else None
    nodes = dict()
    edges = dict()
    for contrib_id in user_graph["contribs"]:
        contrib = db.contribs.find_one({"_id" : ObjectId(contrib_id)})
        contrib_url =  filter(lambda x: x["ref"] == contrib_id, user["contribs"])[0]["url"]
        items = contrib["items"] if ("items" in contrib) else []
        def map_node(node_name):
            pos = [-1, -1]
            if nodes_meta:
                node_meta = filter(lambda x: x["id"] == node_name,  nodes_meta)
                if len(node_meta) > 0:
                    pos = node_meta[0]["pos"]
            return {"id": node_name, "name": node_name, "meta" : {"pos" : pos}}
        for item in items:
            node_name_1 = node_name = item["name_1"]
            if node_name not in nodes:
                nodes[node_name] = map_node(node_name)
            node_name_2 = node_name = item["name_2"]
            if node_name not in nodes:
                nodes[node_name] = map_node(node_name)
            if node_name_1 < node_name_2:
                s = node_name_1
                node_name_1 = node_name_2
                node_name_2 = s
            edge_name = node_name_1 + " " + node_name_2
            if  edge_name in edges:
                edge = edges[edge_name]
                for item_tag in item["tags"]:
                    edge_tag = filter(lambda x: x["name"] == item_tag["name"] and x["type"] == item_tag["type"], edge["tags"])
                    if len(edge_tag) > 0:
                        edge_tag = edge_tag[0]
                        if contrib_url not in edge_tag["urls"]:
                            edge_tag["urls"].append(contrib_url)
                    else:
                        item_tag["urls"] = [contrib_url]
                        edge["tags"].append(item_tag)

            else:
                edge = {"id": edge_name, "source_id": node_name_1, "target_id": node_name_2, "tags" : item["tags"]}
                for tag in edge["tags"]: tag["urls"] = [contrib_url]
                edges[edge_name] = edge

    return {"id": graph_id, "isYours": is_yours, "owner" : user["_id"], "name": graph_name, "nodes": nodes.values(), "edges": edges.values()}

def get_contrib(user_name, contrib_id):
    if not contrib_id:
        contrib_id = _get_default_contrib_id()
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client[config["MONGO_DB"]]
    user_contrib = db.users.find_one({"_id": user_name, "contribs.ref": contrib_id}, {"contribs.$" : 1})["contribs"]
    url = user_contrib[0]["url"]
    contrib_name = user_contrib[0]["name"]
    contrib = db.contribs.find_one({"_id" : ObjectId(contrib_id)})
    contrib_meta = db.contribs.meta.find_one({"_id" : ObjectId(contrib_id)})
    nodes = dict()
    edges = dict()
    items = contrib["items"]
    nodes_meta = contrib_meta["nodes"] if contrib_meta else None
    def map_node(node_name):
        pos = [-1, -1]
        if nodes_meta:
            node_meta = filter(lambda x: x["id"] == node_name,  nodes_meta)
            if len(node_meta) > 0:
                pos = node_meta[0]["pos"]
        return {"id": node_name, "name": node_name, "meta" : {"pos" : pos}}
    for item in items:
        node_name_1 = node_name = item["name_1"]
        if node_name not in nodes:
            nodes[node_name] = map_node(node_name)
        node_name_2 = node_name = item["name_2"]
        if node_name not in nodes:
            nodes[node_name] = map_node(node_name)
        if node_name_1 < node_name_2:
            s = node_name_1
            node_name_1 = node_name_2
            node_name_2 = s
        edge_name = node_name_1 + " " + node_name_2
        if  edge_name in edges:
            edge = edges[edge_name]
            for tag in item["tags"]:
                f_tags = filter(lambda x: tag["type"] == x["type"] and tag["name"] == x["name"], edge["tags"])
            edge["tags"].append(f_tags)
        else:
            edge = {"id": edge_name, "source_id": node_name_1, "target_id": node_name_2, "tags" : item["tags"]}
            edges[edge_name] = edge
        for tag in edge["tags"]:
            tag["urls"] = [url]

    return {"id": contrib_id, "name": contrib_name, "nodes": nodes.values(), "edges": edges.values()}

