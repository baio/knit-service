
+ create index for peron-names, org-names

    http://dbpedia.org/sparql

+ konvert people data from dbpedia to elastic search index structure.

    dbpaedia - russian politic -> elastic search

    ```{ _index: "person-names", _id:"", _type: "politic-rus", val: val, lang: lang, uri: uri }```

```
  select ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?s a yago:RussianPoliticians.
                optional { ?s foaf:givenName ?given_name }
		        optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }
	}

  select ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?s dcterms:subject category:Russian_politicians.
                optional { ?s foaf:givenName ?given_name }
		            optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }

	}

select ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?s dcterms:subject category:Russian_businesspeople.
                optional { ?s foaf:givenName ?given_name }
		            optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }

	}


select distinct ?s
	where
	{
		{?s dcterms:subject category:Russian_businesspeople.}
                union
                {?s dcterms:subject category:Russian_politicians.}
                union
                {?s a yago:RussianPoliticians.}

	}

  select ?s, ?name, ?label, ?foaf_name
	where
	{
		?s a dbpedia-owl:Organisation;
                dbpedia-owl:locationCountry dbpedia:Russia.
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }
                optional { ?s dbpprop:nativeName ?native_name }
	}

```

            select distinct ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name, ?native_name
            where
            {
                ?s ?p ?o.
                optional { ?s foaf:givenName ?given_name }
                optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }
                FILTER (?s = <http://dbpedia.org/resource/Dmitry_Medvedev>)

            }
```

	select ?o
    where {
     <http://dbpedia.org/resource/Dmitry_Medvedev> ?p ?o.
     ?p rdfs:range ?r.
     ?r rdfs:subClassOf dbpedia-owl:Organisation.
    }


select distinct ?p, ?o
    where {
     <http://dbpedia.org/resource/Dmitry_Medvedev> ?p ?o.
     ?o a dbpedia-owl:Person.
    }

```

dbpedia-owl:Organisation


  Sparql queries often have missing info, when queries executed for batch of resources.
  For example when we rquest info for this particular resource result includes names and labels (for batch request not)

	select ?name, ?label
    where {
     <http://dbpedia.org/resource/Nikolay_Yusupov> dbpprop:name ?name;
      rdfs:label ?label.
    }


  Here simpliest implementation, just load data from dbpedia in json format and convert it.


