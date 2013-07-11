dbpedia = require "./dbpedia"
queries = require "./queries"

opts =
  name : "person"
  query : (offset) ->
    queries.peopleReq.replace("{0}", 100).replace("{1}", offset)

exports.start = (done) ->
  dbpedia.start opts, done
    