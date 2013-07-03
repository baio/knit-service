async = require "async"
req = require "request"

_config = null

exports.setConfig = (config) ->
  _config = config

_q = (uri, method, data, done) ->
  body = JSON.stringify(data) if data
  console.log uri, data
  req
    uri : uri
    method: method
    body : body
    headers :
      'content-type': 'application/json'
      'X-Stream' : true
  , (err, resp) ->
      if !err
        j = if resp.body then JSON.parse resp.body else null
      err = j if Array.isArray(j) and j[0] and (j[0].status < 200 or j[0].status > 299)
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

#http://docs.neo4j.org/chunked/milestone/rest-api-unique-indexes.html
exports.createLabels = (id, labels, done) ->
  if typeof id == "object"
    url = id.labels
  else
    url = "#{_config.uri}/node/#{id}/labels"
  _q url, "post", labels, done


exports.createNodesBatch = (nodeOpts, nodes, done) ->

  data = nodes.map (m) ->
    q = _getCreateNode nodeOpts.index, nodeOpts.keyVal(m), nodeOpts.properties(m), nodeOpts.strategy
    method : q.method
    to : q.path
    body: q.data

  console.log data
  _q _config.uri + "/batch", "post", data, done

exports.createRelationsBatch = (relOpts, rels, done) ->

  data = rels.map (m) ->
    q = _getCreateRelation relOpts.index, relOpts.type(m), relOpts.keyVal(m), relOpts.startId(m), relOpts.endId(m), relOpts.properties(m), relOpts.strategy
    method : q.method
    to : q.path
    body: q.data

  console.log data
  _q _config.uri + "/batch", "post", data, done


_getGetRelation = (startId, type) ->

  if typeof startId == "object"
    startUrl = startId.self
  else
    startUrl = "/node/#{startId}"

  path : "#{startUrl}/relationships/all/#{type}"
  method : "get"


exports.getRelation = (startId, type, done) ->
  q = _getGetRelation startId, type
  console.log q
  _q _config.uri + q.path, q.method, null, done


_createNodes = (nodeOpts, nodes, done) ->

  batch = []
  for node in nodes
    b = method : "post"
    batch.push b
    if nodeOpts.index
      b.to =  "/index/node/#{nodeOpts.index}?uniqueness=get_or_create"
      key = Object.keys(nodeOpts.keyValue(node))[0]
      b.body =
        key : key
        value : encodeURIComponent(nodeOpts.keyValue(node)[key])
    else
      b.to = "/node"

  _q _config.uri + "/batch", "post", batch, done

_createNodesProperties = (nodeOpts, nodes, neoNodes, done) ->
  console.log neoNodes
  batch = []
  for neoNode, i in neoNodes
    node = nodes[i]
    body = neoNode.body
    props = nodeOpts?.properties(node)
    if props
      for own prop of props
        batch.push
          method : "put"
          to : body.property.replace(_config.uri, "").replace("{key}",  prop)
          body : props[prop]
  _q _config.uri + "/batch", "post", batch, done


#http://docs.neo4j.org/chunked/milestone/rest-api-node-properties.html
exports.createBatch = (batch, done) ->

    async.waterfall [
      (ck) -> _createNodes batch.nodeOpts, batch.nodes, ck
      (neoNodes, ck) -> _createNodesProperties batch.nodeOpts, batch.nodes, neoNodes, ck
      #(ck, neoNodes) -> _createRelations neoNodes, rels ck
      #(ck, neoRels) -> _createRelationsProperties neoRels, rels, ck
    ], done






























