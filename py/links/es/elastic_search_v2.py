# -*- coding: utf-8 -*-
__author__ = 'baio'

import requests as req
import simplejson as json
import yaml
import os

_elastic_host_url = os.getenv("ES_URI", None)

print _elastic_host_url

def search(index, type, q):
    res = req.post(_elastic_host_url + "/_search?size=1000", data=q)
    print res.content
    content = yaml.load(res.content)
    return [h["_source"] for h in content["hits"]["hits"]]

"""
index - set type
type - field type
l - list with buckets: (key, val)
val_field_name = "val", name of the value field in es
"""
def mset(index, type, l, val_field_name = "val"):
    if not _elastic_host_url or len(l) == 0: return []
    def data2idx(i):
        return u"{}\n{}\n".format(
            json.dumps({"index" : {"_index" : index, "_type" : type, "_id" : i[0]}}),
            json.dumps({val_field_name : i[1]} if val_field_name else i[1]))

    d = "".join(map(data2idx, l))
    print d
    res = req.post(_elastic_host_url + "/_bulk", data=d)
    content = yaml.load(res.content)
    return map(lambda x: x["index"]["ok"] if "index" in x else x["create"]["_id"], content["items"])

"""
l - list of buckets
(index, type, id, val)
"""
def bset(l):
    if not _elastic_host_url or len(l) == 0: return []
    def data2idx(i):
        return u"{}\n{}\n".format(
            json.dumps({"index" : {"_index" : i[0], "_type" : i[1], "_id" : i[2]}}),
            json.dumps(i[3]))

    d = "".join(map(data2idx, l))
    print d
    res = req.post(_elastic_host_url + "/_bulk", data=d)
    content = yaml.load(res.content)
    return map(lambda x: x["index"]["ok"] if "index" in x else x["create"]["_id"], content["items"])

def get(index, type, val, ex_filter = None, val_field_name = "val", search_val_field_name = "val.autocomplete", id_field_name = "_id"):
    if not _elastic_host_url: return []
    d = {"query": {
        "bool": {
            "must": {
                "fuzzy": {
                    search_val_field_name : val
                }
            }
        }
    }}
    if ex_filter:
        d["query"]["bool"].update({"must" : ex_filter})
    res = req.post(_elastic_host_url + "/" + index + "/" + type + "/_search", data=json.dumps(d))
    hits = yaml.load(res.content)["hits"]
    hits = hits["hits"] if len(hits) > 0 else []
    return map(lambda x: (x[id_field_name] if id_field_name == "_id" else x["_source"][id_field_name],
                          x["_source"][val_field_name], x["_index"], x["_type"]), hits)
