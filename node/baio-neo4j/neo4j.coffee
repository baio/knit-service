async = require "async"
req = require "request"

_config = null

exports.setConfig = (config) ->
  _config = config

#http://docs.neo4j.org/chunked/milestone/rest-api-cypher.html

exports.query = (query, params, done) ->
  data =
    query : query
    params : params
  req
    uri : _config.uri
    method: "get"
    body : JSON.stringify(data)
    headers :
      'content-type': 'application/json'
      'X-Stream' : true
    , (err, res) ->
      done err, res.body