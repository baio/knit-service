__author__ = 'baio'

from dom.user.update_contrib_from_lines import update_contrib_from_lines as upd_from_lines
from dom.user.update_contrib_from_gexf import update_contrib_from_gexf as upd_from_gexf
from dom.user.compile_graph import compile_graph
from dom.user.update_gexf_from_graph import update_gexf_from_graph
from dom.user.update_contrib_from_json import update_contrib_from_json as upd_from_json

def update_contrib_from_lines(user, contrib, lines):
    errs = upd_from_lines(user, contrib, lines)
    if len(errs) ==  0:
        compile_graph(user, [contrib], contrib)
        update_gexf_from_graph(user, contrib)
    return errs

def update_contrib_from_json(user, json):
    errs = upd_from_json(user, json)
    if len(errs) ==  0:
        contrib = json["name"]
        compile_graph(user, [contrib], contrib)
        update_gexf_from_graph(user, contrib)
    return errs

def update_contrib_from_gexf(user, contrib, gexf_xml):
    upd_from_gexf(user, contrib, gexf_xml)
    compile_graph(user, [contrib], contrib)
    update_gexf_from_graph(user, contrib)
