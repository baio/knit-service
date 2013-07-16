# -*- coding: utf-8 -*-
__author__ = 'baio'

import os
from dom.connection import get_db
from  bson.objectid import ObjectId
from py2neo import neo4j, cypher
import urllib
import re
import es_names

def get_linked_nodes_neo(name):
    name = name.encode("utf8")
    graph_db = neo4j.GraphDatabaseService(os.getenv("NEO4J_URI"))
    query = "start n=node:wiki(\"uri:{}\") match n-[r*1..2]-m return n, r, m, n.uri, m.uri, n.type, m.type"\
        .format(urllib.quote(name, safe='~()*!.\''))
    data, metadata = cypher.execute(graph_db, query)

    nodes = dict()
    rels = []

    def map_node(node_name):
        return {"id": node_name, "name": node_name, "meta" : {"pos" : [-1, -1]}}

    def map_rel(rel_type, res):
        node_uri_1 = res[3]
        node_uri_2 = res[4]
        node_type_1 = res[5]
        node_type_2 = res[6]
        if node_type_1 == "person": rel_type = "p"
        if node_type_1 == "org": rel_type = "o"
        if node_type_2 == "person": rel_type += "p"
        if node_type_2 == "org": rel_type += "o"
        uri_1 = urllib.unquote(node_uri_1)
        uri_2 = urllib.unquote(node_uri_2)
        val =  urllib.unquote(rel_type).replace("da:","")
        rel_url_dbpedia_1 = uri_1
        rel_url_wikipedia_1 = re.sub('http://dbpedia.org/resource/','http://en.wikipedia.org/wiki/',rel_url_dbpedia_1)
        rel_url_dbpedia_2 = uri_2
        rel_url_wikipedia_2 = re.sub('http://dbpedia.org/resource/','http://en.wikipedia.org/wiki/',rel_url_dbpedia_2)
        return {
            "id": uri_1 + " " + uri_2,
            "source_id": uri_1,
            "target_id": uri_2,
            "tags" : [
                {
                    "type": rel_type + "-unk",
                    "urls": [rel_url_dbpedia_1, rel_url_wikipedia_1, rel_url_dbpedia_2, rel_url_wikipedia_2],
                    "val": val
                }
            ]
        }

    for rel in data:
        if rel[0].id != rel[2].id:
            uri = urllib.unquote(rel[3])
            nodes[uri] = map_node(uri)
            uri = urllib.unquote(rel[4])
            nodes[uri] = map_node(uri)
            rels.append(map_rel(rel[1][0].type, rel))

    """
    node_keys = map(lambda x: urllib.unquote(x), nodes.keys())

    names = es_names.get_es_names(node_keys)
    """
    for node in nodes:
        nodes[node]["name"] = re.sub(r"\/([^\/]*)$", r"\0", nodes[node]["name"])
        """names.get(nodes[node]["name"], node)"""


    return {"nodes": nodes.values(), "edges": rels}


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
