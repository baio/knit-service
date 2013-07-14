# -*- coding: utf-8 -*-
__author__ = 'baio'
from dom.connection import get_db
from  bson.objectid import ObjectId

def get(user_name, contrib_ref):
    db = get_db()
    user = db.users.find_one({"_id": user_name, "contribs.ref": contrib_ref}, {"contribs.$" : 1})
    contrib_ref = db.contribs.find_one({"_id" : ObjectId(contrib_ref)})
    contrib = user["contribs"][0]
    contrib["items"] = contrib_ref.get("items", [])[::-1]
    if "schemes" in contrib:
        contrib["schemes"] = list(db.contribs.scheme.find({"_id": { "$in" : contrib["schemes"]}}))
    for item in contrib["items"]:
        item["_id"] = str(item["_id"])
        item["relations"] = [{"val" : u"друг", "type": "pp-family"}]
        for tag in item["tags"]:
            item["{}_rel".format(tag["type"])] = tag["name"]
        del item["tags"]
    return contrib


