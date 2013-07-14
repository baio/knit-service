__author__ = 'baio'

from dom.connection import get_db
import es.elastic_search_v2 as es
import utils.array as utils_array

def item_field_2_index_doc(item_field_val, field_scheme):
    if isinstance(item_field_val, list):
        for v in item_field_val:
            for doc in item_field_2_index_doc(v, field_scheme):
                yield doc
    else:
        if isinstance(item_field_val, str) or isinstance(item_field_val, unicode):
            type = field_scheme["type"]
            val = item_field_val
        else:
            type = item_field_val["type"]
            val = item_field_val["val"]
        yield (field_scheme["index"], type, val, {"val" : val})


def item_2_index_docs(item, scheme):
    res = []
    for field_scheme in scheme:
        res += list(item_field_2_index_doc(item[field_scheme], scheme[field_scheme]))
    return res

def update_via_scheme(items):
    db = get_db()
    schemes = dict()
    upd_index_docs = []
    for item in items:
        if "scheme" in item:
            if item["scheme"] not in schemes:
                scheme = db.contribs.scheme.find_one({"_id": item["scheme"]})
                schemes[item["scheme"]] = scheme
            else:
                scheme = schemes[item["scheme"]]
            del scheme["_id"]
            upd_index_docs +=  item_2_index_docs(item, scheme)
    upd_index_docs = utils_array.unique(upd_index_docs, lambda x: x[2])
    es.bset(upd_index_docs)
