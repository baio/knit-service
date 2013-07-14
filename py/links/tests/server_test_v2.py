# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
import test_utils

from server.server import contrib_patch

class TestDomContrib(unittest.TestCase):

    def setUp(self):
        pass
        #tu = test_utils.TestUtils()
        #tu.remove_collections()
        #tu.create_def_user()

    def test_create(self):
        val = {
            "id": "518b989739ed9714289d0bc1",
            "items": [
                {
                    "_id": None,
                    "_isRemoved": None,
                    "date": None,
                    "dateTo": None,
                    "name_1": u"ааа ббб",
                    "name_2": u"ввв ггг",
                    "relations": [
                        {
                            "type": "pp-private",
                            "val": "тест"
                        }],
                    "source": None,
                    "url": "test",
                    "scheme": "person-person.ru"
                }]
        }
        contrib_patch("twitter@baio1980", val["id"], val["items"])

if __name__ == '__main__':
    unittest.main()



