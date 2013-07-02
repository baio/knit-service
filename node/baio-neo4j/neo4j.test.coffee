neo = require "./neo4j"

neo.setConfig  uri : process.env.NEO4J_URI

cypherQuery = ->
  neo.query "start n=node(*) return n, labels(n), id(n);" , null, (err, data) ->
    console.log err, data


createNode = (uri) ->
  neo.createNode "wiki", {uri : uri}, {uri : uri}, "get_or_create", (err, data) ->
    console.log err, data

createLabels = (id) ->
  neo.createLabels id, ["huiki", "check"], (err, data) ->
    console.log err, data

createRelation = (uri, n1, n2) ->
  neo.createRelation "wiki", "friend", {uri : 3}, 15, 16, {uri : 3}, "get_or_create", (err, data) ->
    console.log err, data

createNodesBatch = ->
  neo.createNodesBatch
    index : "wiki", keyVal : ((p) -> uri : p.uri), properties : ((p) -> uri : p.uri), strategy :  "get_or_create"
    [{uri : 1}, {uri : 4}]
    (err, data) ->
      console.log err, data

createRelationsBatch = ->
  neo.createRelationsBatch {
    index : "wiki"
    type: "friend"
    keyVal : ((p) -> uri : p.uri)
    startId : ((p) -> p.startId)
    endId : ((p) -> p.endId)
    properties : ((p) -> p.data)
    strategy :  "get_or_create"
  },
  [{uri : 101, startId : 15, endId : 16, data : {uri : 101 }}],
  (err, data) ->
      console.log err, data

setNodeProperties = (id) ->
  neo.setNodeProperties id, names : ["test"], (err, data) ->
    console.log err, data

getRelation = (id) ->
  neo.getRelation id, "friend", (err, data) ->
    console.log err, data


getRelation 109

#setNodeProperties 15
#createNode(2)
#createRelation(3, 15, 16)
#createNodesBatch()
#createRelationsBatch()