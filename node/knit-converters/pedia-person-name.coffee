_q = require "./pedia-query"

name_query = """
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

parse = (bindings) ->

  i = bindings[0]
  id = i.s.value
  if i.sur_name
    en_name = (i.sur_name.value + " " + i.given_name.value).toLocaleLowerCase()
  else
    spts = id.match(/^(.*)\/(.*)$/)[2].split('_')
    en_name = (spts[1] + " " + spts[0]).toLocaleLowerCase()

  item = {id: id, en_name: en_name, ru_name: null}

  for i in bindings
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

  item



module.exports = (uri, s, done) ->
  q = name_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse b
    done err, d


