# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from dom.graph.get_linked_nodes import get_linked_nodes

class TestNeo4j(unittest.TestCase):

    def test_get_linked_nodes(self):
        name = (u"ломейко александр")
        get_linked_nodes(name)

if __name__ == '__main__':
    unittest.main()


