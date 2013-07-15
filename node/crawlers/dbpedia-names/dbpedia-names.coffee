
craw = require "../../baio-crawler/crawler"
queries = require "./queries"
parser = require "./parser"

getPediaQueryData = (query, level, data) ->
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

###
  Levels :
  0. null - request to dbpedia
  1. 0 - parse dbpedia response
###
onPop = (level, body, data, done) ->
  try
    q = []
    if level == null
      parser.parseKeys data, (err, keys) ->
        #q.push getPediaQueryData exports.predicateNameReq.replace("{0}", " or ".join(keys.predicates.map(m) -> "?s=<#{m}>")), 0, type : "predicate"
        if !err
          if keys.people.length
            q.push getPediaQueryData queries.personNameReq.replace("{0}", (keys.people.map((m) -> "?s=`iri('#{m}')`")).join(" or ")), 0, type : "person"
          if keys.orgs.length
            q.push getPediaQueryData queries.orgNameReq.replace("{0}", (keys.orgs.map((m) -> "?s=`iri('#{m}')`")).join(" or ")), 0, type : "org"
        done err, q
    else if level == 0
      parser.parseNames JSON.parse(body), data.type, done
  catch ex
    done ex

crawOpts =
  amqp :
    config :
      url : process.env.AMQP_URI #"amqp://localhost"
      prefetchCount : parseInt(process.env.AMQP_PREFETCH_COUNT) #10
    queue : null
  slaveLevel : parseInt(process.env.CRAWLER_SLAVE_LEVEL) #-1
  skipInitial :
    name : process.env.APP_NAME
    val : if process.env.CRAWLER_SKIP_INITIAL == "true" then true else if process.env.CRAWLER_SKIP_INITIAL == "false" else null
  log :
    loggly:
      level: parseInt(process.env.CRAWLER_LOG_LEVEL_LOGGLY)
      domain: process.env.LOGGLY_DOMAIN
      username: process.env.LOGGLY_USERNAME
      password: process.env.LOGGLY_PASSWORD
      input: process.env.APP_NAME
    console:
      level: parseInt(process.env.CRAWLER_LOG_LEVEL_CONSOLE)

exports.start = (done) ->
  crawOpts.amqp.queue = process.env.APP_NAME
  craw.start crawOpts, onPop, done
