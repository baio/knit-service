_q = require "./pedia-query"

name_query = """

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


checkRuName = (n) ->

  if !n then return null

  name = n.value.toLowerCase()
  name_lang = n["xml:lang"]

  if name_lang == "en" or name_lang == "uk"
    if name.match /^[\u0400-\u04FF\s]+$/gi
      return name

  return null

checkEnName = (n) ->

  if !n then return null

  name = n.value.toLowerCase()
  name_lang = n["xml:lang"]
  if name_lang == "en" or name_lang == "uk"
    return name
  else
    return null

getRuName = (i) ->
  name = checkRuName i.name
  label = checkRuName i.label
  foaf_name = checkRuName i.foaf_name
  r = ""
  for n in [name, label, foaf_name]
    if !r or (n and n.length < r.length)
      r = n
  return r

getEnName = (i) ->
  name = checkRuName i.name
  label = checkRuName i.label
  foaf_name = checkRuName i.foaf_name
  if name then name = null else name = checkEnName i.name
  if label then label = null else label = checkEnName i.label
  if foaf_name then foaf_name = null else name = checkEnName i.foaf_name
  r = ""
  for n in [name, label, foaf_name]
    if !r or (n and n.length < r.length)
      r = n
  return r

#convert json triplestore to dom structure
parse = (bindings) ->

  item = id: null, en_name: "", ru_name: ""

  for i in bindings

    item.id = i.s.value

    #trying to get ru-name

    #trying to get @ru name, sometimes in @en strings stored @ru names, check charsets explicitly
    #chack name and foaf_name fields
    ru_name = getRuName(i)
    en_name = getEnName(i)

    if !item.ru_name or (ru_name and item.ru_name.length > ru_name.length)
      item.ru_name = ru_name

    if !item.en_name or (en_name and item.en_name.length > en_name.length)
      item.en_name = en_name

  item

module.exports = (uri, s, done) ->
  q = name_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse b
    done err, d


