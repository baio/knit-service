craw = require "../baio-crawler/crawler"
queries = require "./queries"
parser = require "./parser"

getQueryData = (query, level, data) ->
  "request":
    "uri": "http://dbpedia.org/sparql"
    "method":"get"
    "qs":
      "default-graph-uri" : "http://dbpedia.org",
      "query" : query,
      "format":"application/sparql-results+json"
      "timeout":30000
  "data": data
  "level" : level

onPop = (level, body, data, done) ->
  try
    q = []
    if level == -1
      #initial query
      q.push getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", 0), 0,{offset : 0, type : "people_list"})
    else
      j = JSON.parse(body)
      if data.type == "people_list"
        people = parser.parsePeople(j)
        offset = data.offset + 100
        for person in people
          q.push getQueryData(queries.subjectPersonLinks.replace("{0}", person), 1, {subject : person, type : "person_person"})
          q.push getQueryData(queries.subjectOrgLinks.replace("{0}", person), 1, {subject : person, type : "person_org"})
        #next query
        q.push getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", offset), 0, {offset : offset, type : "people_list"})
      else if data.type == "person_person" or data.type == "person_org"
        parser.parseLinks(j, data)
    done null, q
  catch ex
    done ex

opts =
  amqp :
    config :
      url : "amqp://localhost"
      prefetchCount : 50
    queue : "baio-crawler"
  slaveLevel : 1
  log :
    level : 0
    write: (level, code, msg) ->
      console.log level, code, msg

craw.start opts, onPop, (err) ->
  console.log "started", err
