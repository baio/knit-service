# -*- coding: utf-8 -*-
__author__ = 'baio'

import unittest
from dom.user.update_contrib_from_lines import update_contrib_from_lines
from dom.user.compile_graph import compile_graph
from dom.user.update_gexf_from_graph import update_gexf_from_graph
from dom.user.update_contrib_from_gexf import update_contrib_from_gexf

class TestDomUser(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_upload(self):
        update_contrib_from_lines("baio", "my-own", [u"елена скрынник-виктор христенко-брат.служба,http://goo.gl/ohEX4"])
        update_contrib_from_lines("baio", "my-own", [u"елена скрынник-виктор христенко-брат.муж,http://goo.gl/ohEX4"])
        update_contrib_from_lines("baio", "my-own", [u"ирина сакаева-лев григорьев-друг,http://goo.gl/ohEX4"])
        update_contrib_from_lines("baio", "my-own-1", [u"ирина сакаева-лев григорьев-друг,http://goo.gl/ohEX4"])
        update_contrib_from_lines("baio2", "my-own", [u"елена скрынник-виктор христенко-брат.служба,http://goo.gl/ohEX4"])



    def test_compile(self):
        compile_graph("baio", ["gov-ru"], "gov-ru")

    @unittest.skip("demonstrating skipping")
    def test_graph2gexf(self):
        update_gexf_from_graph("baio", "grp1")

    @unittest.skip("demonstrating skipping")
    def test_update_contrib_from_gexf(self):
        print "test"
        with open("gephi/layout.gexf") as f:
            update_contrib_from_gexf("baio", "gov-ru", f.read())

if __name__ == '__main__':
    unittest.main()



