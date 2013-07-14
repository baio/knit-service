__author__ = 'baio'


from dom.connection import get_db
import datetime as dt
from  bson.objectid import ObjectId

def copy(user_id, contrib_ref_from):

    db = get_db()

    src_user = db.users.find_one({"contribs.ref": contrib_ref_from}, {"name": 1, "contribs.$": 1})

    if src_user["_id"] == user_id:
        raise ValueError("Contib couldn't be copied to the same user")

    user_contrib =  src_user["contribs"][0]
    contrib = db.contribs_v2.find_one({"_id": ObjectId(contrib_ref_from)})
    contrib["_id"] = ObjectId()

    user_contrib.update({"ref": str(contrib["_id"]), "date": dt.datetime.now(),
                         "copied_from": {"user": src_user["_id"], "contrib": contrib_ref_from}})

    db.contribs_v2.insert(contrib)

    db.users.update({"_id": user_id}, {"$push" : {"contribs" :  user_contrib}})


