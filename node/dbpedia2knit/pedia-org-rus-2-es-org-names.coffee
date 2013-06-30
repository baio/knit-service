fs = require "fs"
req = require "request"
es = require "../es/es"
async = require "async"

_SPARQL_URI = "http://dbpedia.org/sparql"
_RQ_TEMPLATE = "dbpedia_org_request_template.txt"

checkRuName = (n) ->
  if !n then return null
  name = n.value.toLowerCase()
  name_lang = n["xml:lang"]

  if name_lang == "en" or name_lang == "uk"
      if name.match /^[\u0400-\u04FF\s]+$/gi
        return name
  else
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
jsonSparql2struct = (j) ->

  latest = null

  res = []

  for i in j.results.bindings

    #consider given_name and sur name as persistent indentifeier (always english)


    id = i.s.value.toLowerCase()

    if id != latest

      item = {id: id, en_name: "", ru_name: ""}
      res.push item

      latest = id

    #trying to get ru-name

    #trying to get @ru name, sometimes in @en strings stored @ru names, check charsets explicitly
    #chack name and foaf_name fields
    ru_name = getRuName(i)
    en_name = getEnName(i)

    if !item.ru_name or (ru_name and item.ru_name.length > ru_name.length)
      item.ru_name = ru_name

    if !item.en_name or (en_name and item.en_name.length > en_name.length)
      item.en_name = en_name

  data = []
  for doc in res
    obj = {_id : doc.en_name, _type: "rus", val: doc.en_name, lang: "en", uri: doc.id}
    data.push obj
    if doc.ru_name
      obj = {_id : doc.ru_name, _type: "rus", val: doc.ru_name, lang: "ru", uri: doc.id}
      data.push obj

  return data

pedia2es = (uri, index, sparqlData, done) ->
  data = jsonSparql2struct sparqlData
  opts = uri: uri, index: index, settingsPath: "./names_index.json"
  es.createIndex opts, (err) ->
    if !err or err.status == 400
      es.bulk uri, index, data, done
    else
      done err

##########################################

exports.convert = (esUri, done)->

  tmpl = fs.readFileSync _RQ_TEMPLATE, "utf-8"
  params = ["?s a dbpedia-owl:Organisation; dbpedia-owl:locationCountry dbpedia:Russia."]

  async.map params, ((prm, ck) ->
    query = tmpl.replace("{0}", "").replace("{1}", "").replace("{2}", prm)
    _createNames(esUri, query, ck)),
    done

_createNames = (esUri, query, done) ->

  console.log query

  data =
    "default-graph-uri" : "http://dbpedia.org",
    "query" : query,
    "format":"application/sparql-results+json"
    "timeout":30000

  req.get uri: _SPARQL_URI, qs: data, (err, data) ->
    if !err
      pedia2es esUri, "org-names", JSON.parse(data.body), done
    else
      done err
