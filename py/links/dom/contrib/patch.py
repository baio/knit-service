__author__ = 'baio'

from dom.connection import get_db
from  bson.objectid import ObjectId
from dom.contrib.get_graphs import get_graphs
import re

def _wrangling(data):
    def remove_spaces(value):
        return re.sub('\s+', ' ', value)
    clean_ops = [unicode.strip, remove_spaces, unicode.lower]
    for item in data:
        for func in clean_ops:
            item["name_1"] = func(item["name_1"])
            item["name_2"] = func(item["name_2"])
            rel = item.get("family_rel", "")
            if rel:
                item["family_rel"] = func(rel)
            rel = item.get("prof_rel", "")
            if rel:
                item["prof_rel"] = func(rel)
            rel = item.get("private_rel", "")
            if rel:
                item["private_rel"] = func(rel)

def _validate(data):
    #names not empty
    #names consists of 2 words
    #one of the rel exists
    #existsent rel not empty
    #es similar names
    #es similar rels
    return [{"errs": [], "warns": []}] * len(data)

def _json2dom(item):
    dom = {"object": item["name_1"], "subject": item["name_2"]}
    if item["_id"] is not None:
        dom["_id"] = ObjectId(item["_id"])
    else:
        dom["_id"] = ObjectId()
    dom["url"] = item["url"]
    dom["source"] = item["source"]
    dom["date"] = item["date"]
    dom["dateTo"] = item["dateTo"]
    dom["predicates"] = item["relations"]
    dom["scheme"] = item["scheme"]
    return dom

def patch(user_name, contrib_id, data):
    _wrangling(data)
    _validate(data)

    db = get_db()
    contrib_ref = ObjectId(contrib_id)
    res = map(lambda x: {"_id": x["_id"], "err": [], "warn": []}, data)
    crt_items = []
    for i, item in enumerate(data):
        if item["_id"] is None:
            dom = _json2dom(item)
            crt_items.append(dom)
            res[i]["_id"] = str(dom["_id"])

    upd_items = []
    for item in filter(lambda x: x["_id"] is not None and ("_isRemoved" not in x or not x["_isRemoved"]), data):
        dom = _json2dom(item)
        upd_items.append(dom)

    rm_ids = []
    for item in filter(lambda x: "_isRemoved" in x and x["_isRemoved"], data):
        rm_ids.append(ObjectId(item["_id"]))

    if len(crt_items) > 0:
        db.contribs_v2.update({"_id": contrib_ref}, {"$pushAll" : {"items" : crt_items}})

    if len(upd_items) > 0:
        for upd_item in upd_items:
            db.contribs_v2.update({"_id": contrib_ref, "items._id": upd_item["_id"]}, {"$set": {"items.$" : upd_item}})

    #Waiting for the miracle to come, https://jira.mongodb.org/browse/SERVER-831
    #cnt = db.user.find({"_id": user_name, "contribs.name": contrib_name}, {"contribs.$.data": {"$elemMatch": {"_id" : "name_1_name_3"}}})

    if len(rm_ids) > 0:
        db.contribs_v2.update({"_id" : contrib_ref},
                            {"$pull": {"items" : {"_id" : {"$in" : rm_ids}}}})

    res = {"data": res, "graphs": get_graphs(user_name, contrib_id)}

    return res
