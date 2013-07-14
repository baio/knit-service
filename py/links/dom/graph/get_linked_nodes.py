# -*- coding: utf-8 -*-
__author__ = 'baio'

import os
from dom.connection import get_db
from  bson.objectid import ObjectId
from py2neo import neo4j, cypher

def get_linked_nodes(name):
    name = name.encode("utf8")
    db = get_db()
    graph_db = neo4j.GraphDatabaseService(os.getenv("NEO4J_URI"))
    query = "start n=node:person(name=\"{}\") match n-[r]-m return n, r, m;"\
        .format(name)
    data, metadata = cypher.execute(graph_db, query)
    if len(data) == 0:
        return {"nodes": [], "edges": []}
    refs = map(lambda x: x[1].get_properties()["refs"], data)
    plain_refs = sum(refs, [])
    plain_refs = map(lambda x: ObjectId(x), plain_refs)
    agg = db.contribs_v2.aggregate([{"$match" : {"items._id": {"$in" : plain_refs}}}, {"$unwind" : "$items"}, {"$match" : {"items._id": {"$in": plain_refs}}}])
    items = map(lambda x: x["items"], agg["result"])
    i = 0
    res = []
    for ref in refs:
        res.append(items[i:i+len(ref)])
        i += len(ref)
    print res

    def map_node(node_name):
        return {"id": node_name, "name": node_name, "meta" : {"pos" : [-1, -1]}}

    nodes = dict()
    edges = dict()

    for r in res:
        for item in r:
            node_name_1 = node_name = item["object"]
            if node_name not in nodes:
                nodes[node_name] = map_node(node_name)
            node_name_2 = node_name = item["subject"]
            if node_name not in nodes:
                nodes[node_name] = map_node(node_name)
            edge_name = node_name_1 + " " + node_name_2
            if  edge_name in edges:
                edge = edges[edge_name]
                for item_tag in item["predicates"]:
                    edge_tag = filter(lambda x: x["val"] == item_tag["val"] and x["type"] == item_tag["type"], edge["tags"])
                    if len(edge_tag) > 0:
                        edge_tag = edge_tag[0]
                        if item["url"] not in edge_tag["urls"]:
                            edge_tag["urls"].append(item["url"])
                    else:
                        item_tag["urls"] = [item["url"]]
                        edge["tags"].append(item_tag)
            else:
                edge = {"id": edge_name, "source_id": node_name_1, "target_id": node_name_2, "tags" : item["predicates"]}
                for tag in edge["tags"]: tag["urls"] = [item["url"]]
                edges[edge_name] = edge

    return {"nodes": nodes.values(), "edges": edges.values()}
