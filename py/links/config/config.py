__author__ = 'baio'
import os

"""
def _dev_config():
    return {
        "MONGO_URI" : "mongodb://adm:123@ds059957.mongolab.com:59957/knit",
        "MONGO_DB" : "knit",
        "ES_URI" : os.getenv("ES_URI", None)
    }

def _test_config():
    return {
        "MONGO_URI" : "mongodb://adm:123@ds059557.mongolab.com:59557/knit_test",
        "MONGO_DB" : "knit_test",
        "ES_URI" : "http://ec8a279a8973c6f31c23e87e5c5a2f46-us-east-1.foundcluster.com:9200"
    }

def _product_config():
    return {
        "MONGO_URI": os.getenv("MONGO_URI", None),
        "MONGO_DB": os.getenv("MONGO_DB", None),
        "ES_URI": os.getenv("ES_URI", None)
    }

config = {
        "dev": _dev_config,
        "test": _test_config,
        "production": _product_config
    }[os.getenv("ENV", "dev")]()
"""

config = {
    "MONGO_URI" : os.getenv("MONGO_URI", None), #"mongodb://adm:123@ds059957.mongolab.com:59957/knit",
    "MONGO_DB" : os.getenv("MONGO_DB", None),
    "ES_URI" : os.getenv("ES_URI", None)
}
