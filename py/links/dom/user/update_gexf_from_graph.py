# -*- coding: utf-8 -*-
__author__ = 'baio'

import pymongo as mongo
import gridfs
from config.config import config
from dom.gexf import get_gexf_from_dom


def update_gexf_from_graph(user_name, graph_name):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    user = db.user.find_one({"_id": user_name, "graphs.name" : graph_name}, {"graphs" : 1})
    xml = get_gexf_from_dom(user["graphs"][0]["nodes"], user["graphs"][0]["edges"])
    fs = gridfs.GridFS(db)
    file_name = u"{}_{}.gexf".format(user_name, graph_name)
    file_id = None
    if fs.exists(filename=file_name):
        with fs.get_last_version(filename=file_name) as fp:
            file_id = fp._id
    with fs.new_file(filename=file_name, content_type="text/xml") as fp:
        fp.write(xml)
    if file_id:
        fs.delete(file_id)
