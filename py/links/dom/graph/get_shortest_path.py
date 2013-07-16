# -*- coding: utf-8 -*-
__author__ = 'baio'

import os
from dom.connection import get_db
from  bson.objectid import ObjectId
from py2neo import neo4j, cypher
from es import elastic_search_v2 as es
import urllib
import re

def get_es_names(keys):

    q = """
        {
            "query": {
                "bool": {
                    "should": [{0}]
                }
            }
        }
        """

    q_name = """
                {
                    "bool": {
                        "must": {
                            "match": {
                                "key": "{0}"
                            }
                        },
                        "must": {
                            "match": {
                                "lang": "en"
                            }
                        }
                    }
                }
    """

    r = q.replace("{0}", " , ".join(map(lambda key: q_name.replace("{0}", key), keys)))
    print r

    res = dict()
    #lloking for longest names
    for r in es.search("person-names,org-names", "dbpedia", r):
        if len(res.get(r["key"], "")) < len(r["val"]):
            res[r["key"]] = r["val"]
    return res


def get_shortest_path_neo(name_1, name_2):
    name_1 = name_1.encode("utf8")
    name_2 = name_2.encode("utf8")
    hits_1 = es.get("person-names", "dbpedia", name_1, id_field_name="key")
    hits_2 = es.get("person-names", "dbpedia", name_2, id_field_name="key")
    if len(hits_1) > 0 and len(hits_2) > 0:
        key_1 =  urllib.quote(hits_1[0][0], safe='~()*!.\'')
        key_2 = urllib.quote(hits_2[0][0], safe='~()*!.\'')
    else:
        return {"id": None, "isYours": False, "owner" : None, "name": "{}-{}".format(name_1, name_2), "nodes": [], "edges": []}
    graph_db = neo4j.GraphDatabaseService(os.getenv("NEO4J_URI"))
    query = "START n=node:wiki(\"uri:{}\"), m=node:wiki(\"uri:{}\") MATCH p = shortestPath(n-[*]-m) RETURN p;"\
        .format(key_1, key_2)
    data, metadata = cypher.execute(graph_db, query)
    if len(data) == 0 or len(data[0]) == 0:
        return {"id": None, "isYours": False, "owner" : None, "name": "{}-{}".format(name_1, name_2), "nodes": [], "edges": []}

    nodes = dict()
    rels = []

    def map_node(node_name):
        return {"id": node_name, "name": node_name, "meta" : {"pos" : [-1, -1]}}

    def map_rel(rel):
        if rel.nodes[0]["type"] == "person": rel_type = "p"
        if rel.nodes[0]["type"] == "org": rel_type = "o"
        if rel.nodes[1]["type"] == "person": rel_type += "p"
        if rel.nodes[1]["type"] == "org": rel_type += "o"
        uri_1 = urllib.unquote(rel.nodes[0]["uri"])
        uri_2 = urllib.unquote(rel.nodes[1]["uri"])
        val =  urllib.unquote(rel.type).replace("da:","")
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

    for rel in data[0][0].relationships:
        uri = urllib.unquote(rel.nodes[0]["uri"])
        nodes[uri] = map_node(uri)
        uri = urllib.unquote(rel.nodes[1]["uri"])
        nodes[uri] = map_node(uri)
        rels.append(map_rel(rel))

    node_keys = map(lambda x: urllib.unquote(x), nodes.keys())
    names = get_es_names(node_keys)

    for node in nodes:
        nodes[node]["name"] = names.get(nodes[node]["name"], node)

    return {"id": None, "isYours": False, "owner" : None, "name": "{}-{}".format(name_1, name_2), "nodes": nodes.values(), "edges": rels}


def get_shortest_path(name_1, name_2):
    name_1 = name_1.encode("utf8")
    name_2 = name_2.encode("utf8")
    #name_1 = "володин валерий"
    #name_2 = "карманов александр"
    db = get_db()
    graph_db = neo4j.GraphDatabaseService(os.getenv("NEO4J_URI"))
    query = "START n=node:person(name=\"{}\"), m=node:person(name=\"{}\") MATCH p = shortestPath(n-[*]-m) RETURN p;"\
        .format(name_1, name_2)
    data, metadata = cypher.execute(graph_db, query)
    if len(data) == 0:
        return {"id": None, "isYours": False, "owner" : None, "name": "{}-{}".format(name_1, name_2), "nodes": [], "edges": []}
    refs = map(lambda x: x.get_properties()["refs"], data[0][0].relationships)
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

    return {"id": None, "isYours": False, "owner" : None, "name": "{}-{}".format(name_1, name_2), "nodes": nodes.values(), "edges": edges.values()}