__author__ = 'baio'
import pymongo as mongo
import gridfs
from config.config import config

def get_gexf(user_name, graph_name):
    client = mongo.MongoClient(config["MONGO_URI"])
    db = client.links
    fs = gridfs.GridFS(db)
    file_name = u"{}_{}.gexf".format(user_name, graph_name)
    with fs.get_last_version(filename=file_name) as fp:
        return fp.read()