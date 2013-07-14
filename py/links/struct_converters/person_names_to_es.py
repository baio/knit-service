__author__ = 'baio'
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from dom.connection import get_db
from  bson.objectid import ObjectId
from es import elastic_search_v2 as es
from  utils.array import unique

"""
Convert old structure to new one
"""

def convert():
    db = get_db()
    user = db.users.find_one({"_id": "twitter@baio1980"})
    names = []
    tags = []
    for c in user["contribs"]:
        contrib = db.contribs_v2.find_one({"_id": ObjectId(c["ref"])})
        if contrib and "items" in contrib:
            for i in contrib["items"]:
                n = i["object"]
                names.append(n)
                n = i["subject"]
                names.append(n)
                tags += i["predicates"]
    names = map(lambda x: (x, x), set(names))
    tags = unique(tags, lambda x: x["type"] + "_" + x["val"])
    tags = map(lambda x: ("relations.ru", x["type"], x["val"], {"val": x["val"]}), tags)
    es.mset("person-names.ru", "politic-rus", names)
    es.bset(tags)

if __name__ == "__main__":
    convert()




