# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from es import elastic_search as es

class TestContribElastic(unittest.TestCase):

    def test_names_tags_append(self):
        names = [{"fname": "fname_2", "lname": "lname_2"}, {"fname": "fname_1", "lname": "lname_1"}]
        tags = [{"name": "name_1", "type": "type_1"}, {"name": "name_2", "type": "type_2"}]
        es.append_names_tags(names, tags)

    @unittest.skip("demonstrating skipping")
    def test_names_append(self):
        res = es.append_names([u"виктор харитонин"])
        self.assertEquals(len(res), 1)
        self.assertEquals(res[0], True)

    @unittest.skip("demonstrating skipping")
    def test_names_and_tags(self):
        names, tags = list(es.check_names_and_tags([u"ебь гсей", u"еленна скрыник", u"елена скрынник"], [u"лобби", u"браат", u"двоюр"]))

        self.assertEquals(len(names), 3)
        self.assertEquals(names[0], False)
        self.assertEquals(names[1], u"елена скрынник")
        self.assertEquals(names[2], True)

        self.assertEquals(len(tags), 3)
        self.assertEquals(tags[0], True)
        self.assertEquals(tags[1], False)
        self.assertEquals(tags[2], False)

if __name__ == '__main__':
    #es._init("data")
    unittest.main()

