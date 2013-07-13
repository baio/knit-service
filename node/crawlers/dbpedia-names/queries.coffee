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
FILTER ({0})
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
FILTER ({0})
}
"""

