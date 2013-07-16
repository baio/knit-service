__author__ = 'baio'

from es import elastic_search_v2 as es
import urllib

def get_es_names(keys):

    q = """
        {
            "query": {
                "bool": {
                    "should": [{0}]
                }
            }
        }
        """

    q_name = """
                {
                    "bool": {
                        "must": {
                            "match": {
                                "key": "{0}"
                            }
                        },
                        "must": {
                            "match": {
                                "lang": "en"
                            }
                        }
                    }
                }
    """

    r = q.replace("{0}", " , ".join(map(lambda key: q_name.replace("{0}", key), keys)))
    r = r.encode("utf8")

    res = dict()
    #lloking for longest names
    for r in es.search("person-names,org-names", "dbpedia", r):
        if len(res.get(r["key"], "")) < len(r["val"]):
            res[r["key"]] = r["val"]
    return res


def get_es_keys(name):
    hits = es.get("person-names", "dbpedia", name, id_field_name="key")
    if len(hits) > 0:
        return urllib.quote(hits[0][0], safe='~()*!.\'')
    else:
        return None
