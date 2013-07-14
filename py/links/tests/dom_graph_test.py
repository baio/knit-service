# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from dom.graph.get import get_contrib
from dom.graph.post import post_contrib

class TestDomGraph(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_graph_get_contrib(self):
        tst = get_contrib("baio", "518b989739ed9714289d0bc1")
        pass

    def test_graph_post_contrib(self):
        post_contrib("518b989739ed9714289d0bc1", [{"meta":{"pos":[1,5]},"id":"test"}, {"meta":{"pos":[1,7]},"id":"test1"}])

if __name__ == '__main__':
    unittest.main()



