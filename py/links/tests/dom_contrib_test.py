# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
import test_utils
from dom.contrib.create import create
from dom.contrib.update import update
from dom.contrib.merge import merge

class TestDomContribValidate(unittest.TestCase):

    def setUp(self):
        tu = test_utils.TestUtils()
        tu.remove_collections()
        tu.create_def_user()

    @unittest.skip("demonstrating skipping")
    def test_update_errors(self):
        update("baio", "contrib", "contrib-2", "url-2")
        data = [
            {"_id": None, "name_1": "name-1", "name_2": "name-2", "family_rel": u"брат", u"private_rel": "друг"},
            {"_id": None, "name_1": "name-1", "name_2": "name-3", "family_rel": u"муж"}
        ]
        res = merge("baio", "contrib", data)

class TestDomContrib(unittest.TestCase):

    def setUp(self):
        tu = test_utils.TestUtils()
        tu.remove_collections()
        tu.create_def_user()

    def test_create_update_remove(self):
        create("baio", "contrib", "url")
        update("baio", "contrib", "contrib-2", "url-2")
        update("baio", "contrib-2", "contrib", "url")
        data = [
            {"_id": None, "name_1": "name-1", "name_2": "name-2", "family_rel": u"брат", u"private_rel": "друг"},
            {"_id": None, "name_1": "name-1", "name_2": "name-3", "family_rel": u"муж"}
        ]
        res = merge("baio", "contrib", data)
        data = [
            {"_id": res[0]["id"], "name_1": "name-5", "name_2": "name-2", u"private_rel": "друг"},
            {"_id": res[1]["id"], "name_1": "name-1", "name_2": "name-2", "family_rel": u"муж", u"private_rel": "друг"}
        ]
        merge("baio", "contrib", data)
        data = [
            {"_id": res[0]["id"], "_remove": True},
            {"_id": res[1]["id"], "_remove": True},
        ]
        merge("baio", "contrib", data)


if __name__ == '__main__':
    unittest.main()



