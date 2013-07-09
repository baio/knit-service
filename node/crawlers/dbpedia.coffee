craw = require "../baio-crawler/crawler"
queries = require "./queries"
parser = require "./parser"

getQueryData = (query, type, offset) ->
  "request":
    "uri": "http://dbpedia.org/sparql"
    "method":"get"
    "qs":
      "default-graph-uri" : "http://dbpedia.org",
      "query" : query,
      "format":"application/sparql-results+json"
      "timeout":30000
  "data":
    "type": type
    "offset": offset


onPop = (level, body, data, done) ->

  q = []
  if level == -1
    #initial query
    q.push getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", 0), "people_list", 0)
  else
    j = JSON.parse(body)
    people = parser.parsePeople(j)
    if data.type == "people_list"
      offset = data.offset + 100
      for person in people
        q.push getQueryData(queries.subjectPersonLinks.replace("{0}", person), "links")
        q.push getQueryData(queries.subjectOrgLinks.replace("{0}", person), "links")
      #next query
      q.push getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", offset), "people_list", offset)
    else if data.type == "links"
      parser.parseLinks(j)

  done null, q

opts =
  amqp :
    config :
      url : "amqp://localhost"
    queue : "baio-crawler"
  log :
    level : 0
    write: (level, code, msg) ->
      console.log level, code, msg

craw.start opts, onPop, (err) ->
  console.log "started", err
