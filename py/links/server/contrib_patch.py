__author__ = 'baio'
from dom.contrib.patch import patch
from dom.index.update_via_scheme import update_via_scheme as update_index_via_scheme

def contrib_patch(user_name, contrib_id, items):
    res_patch = patch(user_name, contrib_id, items)
    res = res_patch["data"]
    _items = []

    for i, item in enumerate(items):
        if len(res[i]["err"]) == 0 and ("_isRemoved" not in item or item["_isRemoved"] == False):
            _items.append(item)

    update_index_via_scheme(items)

    return res_patch


