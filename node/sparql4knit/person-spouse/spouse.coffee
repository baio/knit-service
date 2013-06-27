###
  select ?src, ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?src a yago:RussianPoliticians;
    dbpedia-owl:spouse ?s.
                optional { ?s foaf:givenName ?given_name }
		optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }


	}

  select ?src, ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?src dcterms:subject category:Russian_politicians.
    dbpedia-owl:spouse ?s.
                optional { ?s foaf:givenName ?given_name }
		optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }


	}

  select ?src, ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?src dcterms:subject category:Russian_businesspeople;
    dbpedia-owl:spouse ?s.
                optional { ?s foaf:givenName ?given_name }
		optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }


	}


###
