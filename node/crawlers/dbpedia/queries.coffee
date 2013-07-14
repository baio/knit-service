exports.peopleReq =
"""
select ?s
where
{
?s a dbpedia-owl:Person.
} limit {0} offset {1}
"""

exports.orgsReq =
"""
select ?s
where
{
?s a dbpedia-owl:Organisation.
}limit {0} offset {1}
"""


exports.subjectPersonLinks =
"""
select ?p, ?o
where {
iri('{0}') ?p ?o.
?o a dbpedia-owl:Person.
}
"""

exports.subjectOrgLinks =
"""
select ?p, ?o
where {
iri('{0}') ?p ?o.
?p rdfs:range ?r.
?r rdfs:subClassOf dbpedia-owl:Organisation.
}
"""