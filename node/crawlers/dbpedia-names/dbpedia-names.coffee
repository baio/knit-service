###
require('nodetime').profile
  accountKey: process.env.NODETIME_KEY,
  appName: 'dbpedia-craw'
###

craw = require "../../baio-crawler/crawler"
queries = require "./queries"
parser = require "./parser"
neo = require "../../baio-neo4j/neo4j"

getNeoQueryData = (query, level, data) ->
  "request": query
  "data": data
  "level" : level

getPediaQueryData = (query, level, data) ->
  "request": query
  "data": data
  "level" : level

neoQuery = (opts, done) ->
  neo.query opts, null, done

###
  Levels :
  1. -1, query to neo
  2. 0 - parse from pedia
  3. 1 - query to pedia
###
onPop = (level, body, data, done) ->
  try
    offset = if level == -1 then 0 else data.offset
    q = []
    if level == -1 or level == 0
      #read nodes
      q.push getNeoQueryData "start n=node(*) return n skip #{offset} limit 1", 0, {offset : offset}
      offset += 1
      if level == 0
        parser.parseNames body, data.type, done
      else
        done null, q
    else if level == 1
      j = JSON.parse(body)
      if j
        node = parser.parseNode(j)
        if node.type == "perosn"
          q.push getPediaQueryData queries.personNameReq.replace("{0}", node.value), 0, {type : "person", offset : offset}
        else if node.type == "org"
          q.push getPediaQueryData queries.personOrgReq.replace("{0}", node.value), 0, {type : "org", offset : offset}
      done null, q
    else
      throw "level out of range"
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
  query : (level) ->
    if level == -1 or level == 0
      return neoQuery
    else
      return null

exports.start = (done) ->
  crawOpts.amqp.queue = process.env.APP_NAME
  craw.start crawOpts, onPop, done
