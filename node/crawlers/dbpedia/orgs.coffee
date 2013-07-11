dbpedia = require "./dbpedia"
queries = require "./queries"

opts =
  name : "org"
  query : (offset) ->
    queries.orgsReq.replace("{0}", 100).replace("{1}", offset)

dbpedia.start opts, (err) ->
  console.log "strated", err