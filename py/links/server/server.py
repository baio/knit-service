# -*- coding: utf-8 -*-
__author__ = 'baio'
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
"""
import web
import simplejson as json
#from es import elastic_search as es
from es import elastic_search_v2 as es

from dom.user.get import get as user_get
from dom.contrib.create import create as contrib_create
from dom.contrib.get_v2 import get as contrib_get
from dom.contrib.delete import delete as contrib_delete
from dom.contrib.update import update as contrib_update
from contrib_patch import contrib_patch
from dom.graph.get_v2 import get as get_graph
from dom.graph.get_shortest_path import get_shortest_path_neo as get_shortest_path
from dom.graph.get_linked_nodes import get_linked_nodes
from dom.graph.get_data import get as get_graph_data
from dom.graph.patch import patch as patch_graph
from dom.graph.post import post as post_graph
from dom.graph.put import put as put_graph
from dom.graph.delete import delete as delete_graph
from dom.push.post import post as post_push
from dom.push.put import put as put_push
from dom.curUser.get import get as curUser_get
from dom.contrib.get_all import get as contrib_get_all
from dom.contrib.copy import copy as contrib_copy
from dom.contrib.get_graphs import get_graphs as get_contrib_graphs
from  bson.objectid import ObjectId

render = web.template.render('gephi/', cache=False)

urls = [
    '/names', 'names',
    '/tags', 'tags',
    '/contribs', 'contribs',
    '/users', 'users',
    '/graphs', 'graphs',
    '/pushes', 'pushes',
    '/curUser', 'curUser',
    '/index', 'index'
]

app = web.application(urls, globals())

def _getUser(input):
    user_name = web.input().get("user", None)
    return user_name if user_name else "twitter@baio1980"

def _jsonforammter(obj):
    if type(obj) == ObjectId: return obj
    return obj.isoformat() if hasattr(obj, 'isoformat') else obj

class pushes:

    def POST(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        d = post_push(input["user"], input["graph_ref"], input["push_user"], input["push_graph"])
        return json.dumps({"ok": True}, default=_jsonforammter)

    def PUT(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        d = put_push(input["user"], input["graph_ref"], input["push_user"], input["status"])
        return json.dumps({"ok": True}, default=_jsonforammter)

class graphs:

    def OPTIONS(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        web.header('Access-Control-Allow-Methods', 'POST, GET, PUT, PATCH, DELETE')

    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = web.input()
        graph_ref = input.get("graph", None)
        user_name = input.get("user", None)
        context = input.get("context", None)
        frm = input.get("from", None)
        to = input.get("to", None)
        src = input.get("src", None)
        if context is None:
            if frm is not None:
                d = get_shortest_path(frm, to)
            elif src is not None:
                d = get_linked_nodes(src)
            else:
                d = get_graph(user_name, graph_ref)
        elif context == "data":
            d = get_graph_data(user_name, graph_ref)
        return json.dumps(d, default=_jsonforammter)

    def PATCH(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        res = patch_graph(input["user"], input["graph"], input["data"])
        if res == 200:
            return json.dumps({"ok": True}, default=_jsonforammter)
        elif res == 401:
            raise web.unauthorized()
        else:
            raise web.internalerror()

    def POST(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        d = post_graph(input["user"], input["name"], input["contribs"])
        return json.dumps(d, default=_jsonforammter)

    def PUT(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        d = put_graph(input["user"], input["id"], input["name"], input["contribs"])
        return json.dumps(d, default=_jsonforammter)

    def DELETE(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = json.loads(web.data())
        id = delete_graph(input["user"], input["ref"])
        return json.dumps({"ok" : True})


class index:

    def GET(self):
        input = web.input()
        res = es.get(input.index, input.type, input.term)
        def map_name(i):
            return {"key": i[0], "val": i[1], "label": i[1], "type": i[3]}
        return json.dumps(map(map_name, res))

class names:

    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        res = es.get("person-names.ru", "politic-rus", web.input().term)
        def map_name(i):
            r = i[0]
            return {"key": r, "val": r, "label": r}
        return json.dumps(map(map_name, res))

class tags:
    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        def map_tag(i):
            r = i[1]
            return {"key": r, "val": r, "label": r}
        res = es.get("relations.ru", web.input().type, web.input().term)
        return json.dumps(map(map_tag, res))


class curUser:

    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        user = web.input().get("user", None)
        name = web.input().get("name", None)
        d = curUser_get(user, name)
        return json.dumps(d, default=_jsonforammter)


class users:

    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        user = web.input()["user"]
        d = user_get(user)
        return json.dumps(d, default=_jsonforammter)

class contribs:

    def GET(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        input = web.input()
        user = input["user"]
        contrib_id = input.get("id", None)
        if contrib_id:
            d = contrib_get(user, contrib_id)
        else:
            d = contrib_get_all(user)
        return json.dumps(d, default=_jsonforammter)

    def POST(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        data = json.loads(web.data())
        d = contrib_create(data["user"], data["name"], data.get("graph_ref", None))
        return json.dumps(d, default=_jsonforammter)

    def OPTIONS(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        web.header('Access-Control-Allow-Methods', 'POST, GET, PUT, PATCH, DELETE, COPY')

    def PUT(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        data = json.loads(web.data())
        d = contrib_update(data["user"], data["ref"], data["name"])
        return json.dumps(d, default=_jsonforammter)

    def PATCH(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        data = json.loads(web.data())
        res = contrib_patch(data["user"], data["id"], data["items"])
        return json.dumps(res)

    def DELETE(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        data = json.loads(web.data())
        res = contrib_delete(data["user"], data["ref"])
        return json.dumps(res)

    def COPY(self):
        web.header('Access-Control-Allow-Origin','*')
        web.header('Access-Control-Allow-Credentials','true')
        web.header('Content-Type', 'application/json')
        data = json.loads(web.data())
        contrib_copy(data["user"], data["ref"])
        return json.dumps({"ok" : True}, default=_jsonforammter)

def run():
    app.run()

if __name__ == "__main__":
    run()

