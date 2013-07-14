# -*- coding: utf-8 -*-
__author__ = 'baio'
import xml.etree.ElementTree as ET

def get_nodes(gexf_xml):
    root = ET.fromstring(gexf_xml)
    return get_nodes_root(root)

def get_nodes_file(gexf_file):
    parser = ET.XMLParser(encoding="utf-8")
    xml = ET.parse(gexf_file, parser)
    return get_nodes_root(xml.getroot())

def get_nodes_root(xml_root):
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
