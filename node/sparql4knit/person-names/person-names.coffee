###
  select ?s, ?given_name, ?sur_name, ?name, ?label, ?foaf_name
	where
	{
		?s a yago:RussianPoliticians.
                optional { ?s foaf:givenName ?given_name }
		            optional { ?s foaf:surname ?sur_name }
                optional { ?s dbpprop:name ?name }
                optional { ?s rdfs:label ?label }
                optional { ?s foaf:name ?foaf_name }

                #filter (!bound(?dateOfDeath))

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

  Sparql queries often have missing info, when queries executed for batch of resources.
  For example when we rquest info for this particular resource result includes names and labels (for batch request not)

	select ?name, ?label
    where {
     <http://dbpedia.org/resource/Nikolay_Yusupov> dbpprop:name ?name;
      rdfs:label ?label.
    }


  Here simpliest implementation, just load data from dbpedia in json format and convert it.

###

fs = require "fs"
req = require "request"

#convert json triplestore to dom structure
jsonSparql2struct = (file) ->

  j = JSON.parse fs.readFileSync file


  latest = null

  res = []

  for i in j.results.bindings

    #consider given_name and sur name as persistent indentifeier (always english)
    if i.given_name

      id = i.s.value.toLowerCase()
      en_name = (i.sur_name.value + " " + i.given_name.value).toLocaleLowerCase()

      if id != latest

        item = {id: id, en_name: en_name, ru_name: null}
        res.push item

        latest = id


      #trying to get @ru name, sometimes in @en strings stored @ru names, check charsets explicitly
      #chack name and foaf_name fields

      if !item.ru_name

        #@ru name still not found

        if i.name
          name = i.name.value.toLowerCase()
          name_lang = i.name["xml:lang"]

        if i.foaf_name
          foaf_name = i.foaf_name.value.toLowerCase()
          foaf_name_lang = i.foaf_name["xml:lang"]

        #trying to detect @ru charset
        if name_lang == "en"
          if name.match /^[\u0400-\u04FF\s]+$/gi
            item.ru_name = name
        if foaf_name_lang == "en"
          if foaf_name.match /[\u0400-\u04FF]+/gi
            item.ru_name = foaf_name

        if item.ru_name
          spt = item.ru_name.split(" ")
          if spt.length == 3
            if spt[0].indexOf(',') != -1
              item.ru_name = item.ru_name.replace(/,/g, '')
            else
              item.ru_name = "#{spt[2]} #{spt[0]} #{spt[1]}"
          else
            item.ru_name = "#{spt[1]} #{spt[0]}"

  return res

#convert dom structure to elactic search bulk update data
struct2es = (struct) ->

  data = ""

  for i in struct

    data += JSON.stringify { "create" : { "_index" : "person-names", "_type" : "politic-rus", "_id" : i.en_name } }
    data += "\r\n"
    data += JSON.stringify { "val": i.en_name, "lang": "en", "key": i.id  }
    data += "\r\n"

    if i.ru_name
      data += JSON.stringify { "create" : { "_index" : "person-names", "_type" : "politic-rus", "_id" : i.ru_name } }
      data += "\r\n"
      data += JSON.stringify { "val": i.ru_name, "lang": "ru", "key": i.id  }
      data += "\r\n"

  data


struct = jsonSparql2struct "russian-buisness.json"

data = struct2es struct

console.log data

req {method: "post", uri : "http://188.244.44.9:9201/person-names/_bulk", body: data}, (err, resp, body) ->
  console.log err
