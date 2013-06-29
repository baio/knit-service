req = require "request"

module.exports = (uri, query, done) ->

  data =
    "default-graph-uri" : "http://dbpedia.org",
    "query" : query,
    "format":"application/sparql-results+json"
    "timeout":30000

  req.get uri: uri, qs: data, (err, data) ->
    if !err
      done null, JSON.parse(data.body).results.bindings
    else
      done err
