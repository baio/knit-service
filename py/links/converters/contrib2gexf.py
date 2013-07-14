# -*- coding: utf-8 -*-
__author__ = 'baio'
import xml.etree.ElementTree as ET
import tag2rel_type

def get_elements(edge_bucks, node_bucks):
    nodes = []
    for name in set([x[0] for x in edge_bucks] + [x[1] for x in edge_bucks]):
        pos = [-1,-1]
        node_buck = filter(lambda x: x[0] == name.replace(" ", "_"), node_bucks)
        if len(node_buck) > 0: pos = node_buck[0][1]
        nodes.append((name, pos))
    return edge_bucks, nodes


def get_xml_elements(edge_bucks, node_bucks):
    def viz_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft/viz', tag) )
    edges, nodes = get_elements(edge_bucks, node_bucks)
    node_els = []
    edge_els = []
    for node in nodes:
        node_el = ET.Element("node")
        node_el.attrib["id"] = node[0].replace(" ", "_").strip()
        node_el.attrib["label"] = node[0].strip()
        attr_pos = ET.Element(viz_tag("position"))
        node_el.append(attr_pos)
        if node[1][0] != -1:
            attr_pos.attrib["x"] = str(node[1][0])
            attr_pos.attrib["y"] = str(node[1][1])
        node_els.append(node_el)
    for edge in edges:
        edge_el = ET.Element("edge")
        edge_el.attrib["source"] = edge[0].replace(" ", "_")
        edge_el.attrib["target"] = edge[1].replace(" ", "_")
        attrs_el = ET.Element("attvalues")
        edge_el.append(attrs_el)
        for rel in edge[2]:
            attr_val_el = ET.Element("attvalue")
            attrs_el.append(attr_val_el)
            attr_val_el.attrib["for"] = tag2rel_type.tag2rel_type(rel)
            attr_val_el.attrib["value"] = rel
        attr_val_el = ET.Element("attvalue")
        attrs_el.append(attr_val_el)
        attr_val_el.attrib["for"] = "url"
        attr_val_el.attrib["value"] = edge[3]
        edge_els.append(edge_el)
    return edge_els, node_els


def merge_xml_elements(edge_bucks, node_bucks, merge_xml):
    def ns_tag(tag):
        return str(ET.QName('http://www.gexf.net/1.2draft', tag) )
    edges, nodes  = get_xml_elements(edge_bucks, node_bucks)
    ET.register_namespace("", "http://www.gexf.net/1.2draft")
    ET.register_namespace("viz", "http://www.gexf.net/1.2draft/viz")
    parser = ET.XMLParser(encoding="utf-8")
    xml = ET.parse(merge_xml, parser)
    xml_root = xml.getroot()
    xml_nodes = xml_root.find(ns_tag("graph")).find(ns_tag("nodes"))
    xml_edges = xml_root.find(ns_tag("graph")).find(ns_tag("edges"))
    for node in nodes:
        xml_nodes.append(node)
    for edge in edges:
        xml_edges.append(edge)
    if merge_xml:
        xml.write(merge_xml, "utf-8", xml_declaration=True)
    return ET.dump(xml)



