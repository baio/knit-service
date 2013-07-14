__author__ = 'baio'
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from dom.connection import get_db
from  bson.objectid import ObjectId

"""
Convert old structure to new one
"""

def convert():
    db = get_db()
    user = db.users.find_one({"_id": "twitter@baio1980"})
    for c in user["contribs"]:
        old_contrib = db.contribs.find_one({"_id": ObjectId(c["ref"])})
        new_contrib = {"_id": ObjectId(c["ref"]), "items": []}
        if old_contrib:
            for i in old_contrib["items"]:
                item = {
                    "_id": i["_id"],
                    "scheme": "person-person.ru",
                    "object": " ".join(i["name_1"].split(" ")[::-1]),
                    "subject": " ".join(i["name_2"].split(" ")[::-1]),
                    "url": c["url"],
                    "predicates": []
                }
                for t in i["tags"]:
                    predicate = {
                        "type": "pp-" + t["type"],
                        "val": t["name"]
                    }
                    item["predicates"].append(predicate)
                new_contrib["items"].append(item)
            db.contribs_v2.save(new_contrib)
        c["schemes"] = ["person-person.ru", "person-org.ru", "org-org.ru"]
    db.users.save(user)

if __name__ == "__main__":
    convert()



