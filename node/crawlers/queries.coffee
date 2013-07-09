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

exports.personNameReq =
"""
select distinct ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
where
{
?s ?p ?o.
optional { ?s foaf:givenName ?given_name }
optional { ?s foaf:surname ?sur_name }
optional { ?s dbpprop:name ?name }
optional { ?s rdfs:label ?label }
optional { ?s foaf:name ?foaf_name }
FILTER (?s = <{0}>)
}
"""

exports.orgNameReq =
"""
select distinct ?s, ?name, ?label, ?foaf_name
where
{
?s ?p ?o.
optional { ?s dbpprop:name ?name }
optional { ?s rdfs:label ?label }
optional { ?s foaf:name ?foaf_name }
optional { ?s dbpprop:nativeName ?native_name }
FILTER (?s = <{0}>)
}
"""

exports.subjectPersonLinks =
"""
select ?o
where {
<{0}> ?p ?o.
?o a dbpedia-owl:Person.
}
"""

exports.subjectOrgLinks =
"""
select ?o
where {
<{0}> ?p ?o.
?p rdfs:range ?r.
?r rdfs:subClassOf dbpedia-owl:Organisation.
}
"""