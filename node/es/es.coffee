req = require "request"

bulk = (uri, index, docs, done) ->
  res = ""
  for doc in docs
    obj = { "index" : { "_index" : index, "_type" : doc._type, "_id" : doc._id } }
    res += JSON.stringify(obj)
    res += "\r\n"
    obj = JSON.parse(JSON.stringify(doc))
    delete obj._id
    delete obj._type
    res += JSON.stringify(obj)
    res += "\r\n"
  req {method: "post", uri : "#{uri}/#{index}/_bulk", body: res}, (err) ->
    done err

copy = (uri, fromIndex, toIndex, docsCount, map, done) ->
  docsCount ?= 1000
  req.get uri : "#{uri}/#{fromIndex}/_search", qs : {size : docsCount}, (err, res) ->
    if !err
      j = JSON.parse(res.body)
      j = j.hits.hits.map (m) -> map m
      console.log j
      bulk uri, toIndex, j, done
    else
      done err

exports.copy = copy
exports.bulk = copy