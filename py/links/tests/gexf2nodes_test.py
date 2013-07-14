# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from converters import gexf2nodes

class TestGexf2nodes(unittest.TestCase):

    def test_get_nodes(self):
        gexf = open("gephi/main.gexf", "r").read()
        print list(gexf2nodes.get_nodes(gexf))

    def test_get_nodes_file(self):
        print list(gexf2nodes.get_nodes_file("gephi/main.gexf"))

if __name__ == '__main__':
    unittest.main()

