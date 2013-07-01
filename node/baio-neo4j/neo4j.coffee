async = require "async"
req = require "request"

_config = null

exports.setConfig = (config) ->
  _config = config

_q = (uri, method, data, done) ->
  req
    uri : uri
    method: method
    body : JSON.stringify(data)
    headers :
      'content-type': 'application/json'
      'X-Stream' : true
  , (err, resp) ->
      if !err
        j = if resp.body then JSON.parse resp.body else null
      done err, j


#http://docs.neo4j.org/chunked/milestone/rest-api-cypher.html
exports.query = (query, params, done) ->
  data =
    query : query
    params : params
  _q _config.uri + "/cypher", "post", data, (err, j) ->
      if !err
        res = []
        for r in j.data
          obj = {}
          res.push obj
          for c, i in j.columns
            obj[c] = r[i]
      done err, res


_getCreateNode = (index, keyVal, properties, strategy) ->
  path : "/index/node/#{index}?uniqueness=#{strategy}"
  method : "post"
  data :
    key : Object.keys(keyVal)[0]
    value : keyVal[Object.keys(keyVal)[0]]
    properties : properties

#http://docs.neo4j.org/chunked/milestone/rest-api-unique-indexes.html
exports.createNode = (index, keyVal, properties, strategy, done) ->
  q = _getCreateNode index, keyVal, properties, strategy
  _q _config.uri + q.path, q.method, q.data, done
  ###
  data =
    key : Object.keys(keyVal)[0]
    value : keyVal[Object.keys(keyVal)[0]]
    properties : properties
  _q _config.uri + "/index/node/#{index}?uniqueness=#{strategy}", "post", data, done
  ###

_getCreateRelation = (index, type, keyVal, startId, endId, properties, strategy) ->
  if typeof startId == "object"
    startUrl = startId.self
  else
    startUrl = "#{_config.uri}/node/#{startId}"

  if typeof endId == "object"
    endUrl = endId.self
  else
    endUrl = "#{_config.uri}/node/#{endId}"

  path:
    "/index/relationship/#{index}?uniqueness=#{strategy}"
  method:
    "post"
  data:
    key : Object.keys(keyVal)[0]
    value : keyVal[Object.keys(keyVal)[0]]
    properties : properties
    start : startUrl
    end : endUrl
    type : type

#http://docs.neo4j.org/chunked/milestone/rest-api-unique-indexes.html
exports.createRelation = (index, type, keyVal, startId, endId, properties, strategy, done) ->
  q = _getCreateRelation index, type, keyVal, startId, endId, properties, strategy
  _q _config.uri + q.path, q.method, q.data, done
  ###
  if typeof startId == "object"
    startUrl = startId.self
  else
    startUrl = "#{_config.uri}/node/#{startId}"

  if typeof endId == "object"
    endUrl = endId.self
  else
    endUrl = "#{_config.uri}/node/#{endId}"

  data =
    key : Object.keys(keyVal)[0]
    value : keyVal[Object.keys(keyVal)[0]]
    properties : properties
    start : startUrl
    end : endUrl
    type : type

  _q (_config.uri + "/index/relationship/#{index}?uniqueness=#{strategy}"), "post", data, done
  ###

#http://docs.neo4j.org/chunked/milestone/rest-api-unique-indexes.html
exports.createLabels = (id, labels, done) ->
  if typeof id == "object"
    url = id.labels
  else
    url = "#{_config.uri}/node/#{id}/labels"
  _q url, "post", labels, done


exports.createBatch = (nodeOpts, nodes, relOpts, rels, done) ->
  n = r = []
  if nodes
    n = nodes.map (m) ->
      q = _getCreateNode nodeOpts.index, nodeOpts.keyVal(m), m, nodeOpts.strategy
      method : q.method
      to : q.path
      body: q.data
  i = 0
  if rels
    r = rels.map (m) ->
      q = _getCreateRelation relOpts.index, relOpts.type, relOpts.keyVal(m), "{#{i}}", "{#{i+1}}", m, relOpts.strategy
      q.data.start = "{0}"
      q.data.end = "{1}"
      method : q.method
      to : q.path
      body: q.data

  data = n.concat(r)
  console.log data
  _q _config.uri + "/batch", "post", data, done
