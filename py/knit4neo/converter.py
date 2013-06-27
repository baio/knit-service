__author__ = 'baio'
import pymongo as mongo
import os

def unique(seq, idfun=None):
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result

def convert():
    print os.getenv("MONGO_URI")
    print os.getenv("MONGO_DB")
    client = mongo.MongoClient(os.getenv("MONGO_URI"))
    db = client[os.getenv("MONGO_DB")]

    for ctb in db.contribs_v2.find():
        nodes = []
        edges = []
        if "items" in ctb:

            for item in ctb["items"]:
                node = {"name": item["object"], "tags": []}
                nodes.append(node)
                node = {"name": item["subject"], "tags": []}
                nodes.append(node)
                for pred in item["predicates"]:
                    edges.append({"type": pred["type"], "val": pred["val"], "obj": item["object"], "subj": item["subject"] })

            nodes = unique(nodes, lambda x: x["name"])
            edges = unique(edges, lambda x: x["val"]+x["type"]+x["obj"]+x["subj"])
            nodes_str = "CREATE UNIQUE " + ", ".join(map(lambda x: "({name: %, tags: []})" % x, nodes))
            edges_str = "START " + ", ".join(map(lambda x:
                "n=node(node_auto_index({name:%}),m=node(node_auto_index({name:%})) CREATE n-[r:% {tags: []}]->m RETURN r" % (x["val"]), edges))
            print nodes_str
            print edges_str


if __name__ == "__main__":
    convert()







