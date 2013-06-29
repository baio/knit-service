fs = require "fs"
req = require "request"
es = require "../es/es"
async = require "async"

_SPARQL_URI = "http://dbpedia.org/sparql"
_RQ_TEMPLATE = "dbpedia_people_request_template.txt"

#convert json triplestore to dom structure
jsonSparql2struct = (j) ->

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

  data = []
  for doc in res
    obj = {_id : doc.en_name, _type: "politic-rus", val: doc.en_name, lang: "en", uri: doc.id}
    data.push obj
    if doc.ru_name
      obj = {_id : doc.ru_name, _type: "politic-rus", val: doc.ru_name, lang: "ru", uri: doc.id}
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
  params = ["?s a yago:RussianPoliticians",
            "?s dcterms:subject category:Russian_politicians",
            "?s dcterms:subject category:Russian_businesspeople"]

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
      pedia2es esUri, "person-names", JSON.parse(data.body), done
    else
      done err
