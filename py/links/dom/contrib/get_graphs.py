__author__ = 'baio'

from dom.connection import get_db

def get_graphs(user_name, contrib_id):
    db = get_db()
    user = db.users.find_one({"_id": user_name, "graphs.contribs": contrib_id}, {"graphs.ref" : 1})
    if user:
        res = map(lambda x: x["ref"], user["graphs"])
        return res
    else:
        return []

