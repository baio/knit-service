async = require "async"
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

map = (uri, fromIndex, toIndex, docsCount, map, done) ->
  docsCount ?= 10000
  req.get uri : "#{uri}/#{fromIndex}/_search", qs : {size : docsCount}, (err, res) ->
    if !err
      j = JSON.parse(res.body)
      j = j.hits.hits.map (m) -> map m
      bulk uri, toIndex, j, done
    else
      done err

copy = (uri, fromIndex, toIndex, done) ->
  map uri, fromIndex, toIndex, null, ((m) -> m), done

del = (uri, index, done) ->
  req uri: "#{uri}/#{index}", method: "delete", (err) -> done err

bkp = (uri, from, to, done) ->
  async.waterfall [
    (ck) -> del uri, to, ck
    (ck) -> copy uri, from, to, ck
  ], done

exports.copy = copy
exports.bulk = bulk
exports.map = map
exports.bkp = bkp
exports.del = del