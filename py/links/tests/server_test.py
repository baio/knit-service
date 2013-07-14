# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from storage import  mongo_storage as mongo
from converters.contrib2gexf import merge_xml_elements
from server.server_post_links import update_links

class TestServer(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_gen_gexf(self):
        edges = list(mongo.get_edges())
        nodes = list(mongo.get_nodes())
        merge_xml_elements(edges, nodes, "gephi/layout.gexf")

    def test_update_links(self):
        update_links(["елена скрынник-виктор христенко-брат.служба,http://goo.gl/ohEX4"])

if __name__ == '__main__':
    unittest.main()


