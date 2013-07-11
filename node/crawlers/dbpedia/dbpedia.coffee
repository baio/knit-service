###
require('nodetime').profile
  accountKey: process.env.NODETIME_KEY,
  appName: 'dbpedia-craw'
###

craw = require "../../baio-crawler/crawler"
queries = require "./queries"
parser = require "./parser"

_opts = null

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
      q.push getQueryData(_opts.query(0), 0,{offset : 0, type : "#{_opts.name}_list"})
      done null, q
    else
      j = JSON.parse(body)
      if data.type == "#{_opts.name}_list"
        bindings = parser.parseBindings(j)
        offset = data.offset + 100
        for binding in bindings
          q.push getQueryData(queries.subjectPersonLinks.replace("{0}", binding), 1, {subject : binding, type : "#{_opts.name}_person"})
          q.push getQueryData(queries.subjectOrgLinks.replace("{0}", binding), 1, {subject : binding, type : "#{_opts.name}_org"})
        #next query
        q.push getQueryData(_opts.query(offset), 0, {offset : offset, type : "#{_opts.name}_list"})
        done null, q
      else if data.type == "#{_opts.name}_person" or data.type == "#{_opts.name}_org"
        parser.parseLinks j, data, (err) ->
          done err, q
  catch ex
    done ex

crawOpts =
  amqp :
    config :
      url : process.env.AMQP_URI #"amqp://localhost"
      prefetchCount : parseInt(process.env.AMQP_PREFETCH_COUNT) #10
    queue : null
  slaveLevel : parseInt(process.env.CRAWLER_SLAVE_LEVEL) #-1
  skipInitial : process.env.CRAWLER_SKIP_INITIAL == "true"
  log :
    level : parseInt(process.env.CRAWLER_LOG_LEVEL)
    write:
      loggly:
        domain: process.env.LOGGLY_DOMAIN
        username: process.env.LOGGLY_USERNAME
        password: process.env.LOGGLY_PASSWORD
        input: process.env.APP_NAME
      console: process.env.CRAWLER_LOG_CONSOLE == "true"

exports.start = (opts, done) ->
  _opts = opts
  crawOpts.amqp.queue = process.env.APP_NAME
  craw.start crawOpts, onPop, done
