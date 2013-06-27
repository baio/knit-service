fs = require "fs"
req = require "request"
es = require "../es/es"

_SPARQL_URI = "http://dbpedia.org/sparql"
_ES_URI = "http://188.244.44.9:9201"
_RQ_TEMPLATE = "dbpedia_request_template.txt"


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

  return res

#convert dom structure to elactic search bulk update data
struct2es = (struct) ->

  data = ""

  for i in struct

    data += JSON.stringify { "create" : { "_index" : "person-names", "_type" : "politic-rus", "_id" : i.en_name } }
    data += "\r\n"
    data += JSON.stringify { "val": i.en_name, "lang": "en", "uri": i.id  }
    data += "\r\n"

    if i.ru_name
      data += JSON.stringify { "create" : { "_index" : "person-names", "_type" : "politic-rus", "_id" : i.ru_name } }
      data += "\r\n"
      data += JSON.stringify { "val": i.ru_name, "lang": "ru", "uri": i.id  }
      data += "\r\n"

  data


###
j = JSON.parse fs.readFileSync file

  struct = jsonSparql2struct "russian-buisness.json"

data = struct2es struct

console.log data

req {method: "post", uri : "http://188.244.44.9:9201/person-names/_bulk", body: data}, (err, resp, body) ->
  console.log err

###

pedia2es = (j, esIndex, done) ->

  struct = jsonSparql2struct j

  data = struct2es struct

  req {method: "post", uri : "#{_ES_URI}/#{esIndex}/_bulk", body: data}, (err) ->
    done err

requestData = ->

  tmpl = fs.readFileSync _RQ_TEMPLATE, "utf-8"

  query = tmpl
    .replace("{0}", "")
    .replace("{1}", "")
    .replace("{2}", "?s a yago:RussianPoliticians")

  data =
    "default-graph-uri" : "http://dbpedia.org",
    "query" : query,
    "format":"application/sparql-results+json"
    "timeout":30000

  req.get uri: _SPARQL_URI, qs: data, (err, data) ->
    if !err
      pedia2es JSON.parse(data.body), "person-names", (err) ->
        console.log err
    else
      console.log err


copyFromOldVersion = ->
  es.copy _ES_URI, "org-names.ru", "org-names", 1000
    ,(m) ->
      _id: m._id
      _type: m._type
      val: m._id
      lang: "ru"
      uri: m._id
    ,(err) ->
      console.log err


copyFromOldVersion()