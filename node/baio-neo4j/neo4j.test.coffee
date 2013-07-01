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

createBatch = ->
  neo.createBatch
    index : "wiki", keyVal : ((p) -> uri : p.uri), strategy :  "get_or_create"
    [{uri : 1}, {uri : 4}]
    index : "wiki", keyVal : ((p) -> uri : p.uri), strategy :  "get_or_create", type : "friend"
    [{uri : 77}]
    (err, data) ->
      console.log err, data

#createNode(2)
#createRelation(3, 15, 16)
createBatch()