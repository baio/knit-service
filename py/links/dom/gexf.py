# -*- coding: utf-8 -*-
__author__ = 'baio'
import xml.etree.ElementTree as ET

def get_nodes_from_gexf(xml):
    xml_root = ET.fromstring(xml)
    def ns_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft', tag) )
    def viz_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft/viz', tag) )
    ET.register_namespace("", "http://www.gexf.net/1.2draft")
    ET.register_namespace("viz", "http://www.gexf.net/1.2draft/viz")
    xml_nodes = xml_root.find(ns_tag("graph")).find(ns_tag("nodes"))
    for node in xml_nodes:
        pos = node.find(viz_tag("position"))
        yield (node.get("id"), [float(pos.get("x")), float(pos.get("y"))])

def _get_attr_rel_for(rel):
    return {
        u"брат" : "family_rel",
        u"муж" : "family_rel",
        u"двоюрод" : "family_rel",
        u"замуж" : "family_rel",
        u"сын" : "family_rel",
        u"друг" : "private_rel",
        u"кореш" : "private_rel",
        u"служба" : "prof_rel",
        u"лобби" : "prof_rel",
        u"партнер" : "prof_rel",
        u"соуч" : "prof_rel"
    }[rel];

def convert_dom2gexf(dom_nodes, dom_edges):
    def viz_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft/viz', tag) )
    node_els = []
    edge_els = []
    for node in dom_nodes:
        node_el = ET.Element("node")
        node_el.attrib["id"] = node["_id"]
        node_el.attrib["label"] = node["_id"].replace("_"," ")
        if "pos" in node:
            attr_pos = ET.Element(viz_tag("position"))
            node_el.append(attr_pos)
            attr_pos.attrib["x"] = str(node["pos"][0])
            attr_pos.attrib["y"] = str(node["pos"][1])
        node_els.append(node_el)
    for edge in dom_edges:
        edge_el = ET.Element("edge")
        spts = edge["_id"].split("_")
        edge_el.attrib["source"] = spts[0] + "_" + spts[1]
        edge_el.attrib["target"] = spts[2] + "_" + spts[3]
        attrs_el = ET.Element("attvalues")
        edge_el.append(attrs_el)
        urls = []
        for tag in edge["tags"]:
            attr_val_el = ET.Element("attvalue")
            attrs_el.append(attr_val_el)
            attr_val_el.attrib["for"] = _get_attr_rel_for(tag["name"])
            attr_val_el.attrib["value"] = tag["name"]
            urls.append(",".join(tag["urls"]))
        attr_val_el = ET.Element("attvalue")
        attrs_el.append(attr_val_el)
        attr_val_el.attrib["for"] = "url"
        attr_val_el.attrib["value"] = "|".join(urls)
        edge_els.append(edge_el)
    return edge_els, node_els

def get_gexf_from_dom(dom_nodes, dom_edges):
    def ns_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft', tag) )
    edges, nodes  = convert_dom2gexf(dom_nodes, dom_edges)
    ET.register_namespace("", "http://www.gexf.net/1.2draft")
    ET.register_namespace("viz", "http://www.gexf.net/1.2draft/viz")
    parser = ET.XMLParser(encoding="utf-8")
    xml = ET.parse("gephi/_layout.gexf", parser)
    xml_root = xml.getroot()
    xml_nodes = xml_root.find(ns_tag("graph")).find(ns_tag("nodes"))
    xml_edges = xml_root.find(ns_tag("graph")).find(ns_tag("edges"))
    for node in nodes:
        xml_nodes.append(node)
    for edge in edges:
        xml_edges.append(edge)
    return ET.tostring(xml_root)

