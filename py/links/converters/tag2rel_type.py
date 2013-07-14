# -*- coding: utf-8 -*-
__author__ = 'baio'

def tag2rel_type(tag):
    return {
        u"брат" : "family_rel",
        u"муж" : "family_rel",
        u"двоюрод" : "family_rel",
        u"замуж" : "family_rel",
        u"сын" : "family_rel",
        u"друг" : "private_rel",
        u"кореш" : "private_rel",
        u"служба" : "prof_rel",
        u"лобби" : "prof_rel",
        u"партнер" : "prof_rel",
        u"соуч" : "prof_rel"
    }[tag]

