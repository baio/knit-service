# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from es import elastic_search_v2 as es

class TestContribElastic_v2(unittest.TestCase):

    def test_mset(self):
        return
        names = [(u"васильева евгения", u"васильева евгения"), (u"васильев николай", u"васильев николай")]
        es.mset("person-names.ru", "politic-rus", names)

    def test_mset_tag(self):
        return
        rels = [("друг", "друг")]
        es.mset("relations.ru", "pp-private", rels)

    def test_get(self):
        return
        res = es.get("person-names.ru", "politic-rus", u"васел")
        print res

    def test_get_tag(self):
        res = es.get("relations.ru", "pp-private", u"дри")
        print res

if __name__ == '__main__':
    unittest.main()

