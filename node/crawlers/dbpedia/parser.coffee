_ = require "underscore"
inflect = require "underscore.inflections"
neo = require "../../baio-neo4j/neo4j"
amqp = require "../../baio-amqp/amqp"

neo.setConfig uri: process.env.NEO4J_URI

alignPredicate = (predicate) ->

  #get latest item in path, remove (es?), make singular
  p = "#{predicate.toLowerCase().match(/^.*\/(.*)$/)[1]}"
  p = inflect.singularize p
  "da:" + p

_getNodeType = (link, isSubject) ->
  if isSubject
    switch link.type
      when "person_person" then "person"
      when "person_org" then "person"
      else return "org"
  else
    switch link.type
      when "person_person" then "person"
      when "org_person" then "person"
      else return "org"

_getNodes = (links) ->
  nodesSubj = links.map((l) -> node: l.subject, type: _getNodeType(l, true))
  nodesObj = links.map((l) -> node: l.object, type: _getNodeType(l, false))
  nodesSubj.concat nodesObj

push2namesParser = (data) ->
  #send to parse-names queue
  nodes = _.uniq _getNodes(data.links), false, (i) -> JSON.stringify(i)
  amqp.pub process.env.CRAWLER_NAMES_APP_NAME, predicates : data.predicates, nodes : nodes

store2neo = (links, done) ->

  if links.length == 0
    done(null, [])
    return

  nodes = _getNodes links

  i = 0
  for l, i in links
    l.nodes = [i, i + 1]
    i += 2

  batch =
    nodeOpts:
      index: "wiki"
      keyValue: (m) -> uri : m.node
      properties: (m) -> type : m.type
    nodes: nodes
    relOpts:
      type: (m) -> m.predicate
      nodesIndexes: (m) -> m.nodes
    rels : links

  neo.createBatch batch, done

exports.parseBindings = (batch) ->

  batch.results.bindings.map (d) -> d.s.value

exports.parseLinks = (batch, data, done) ->

  linked = batch.results.bindings.map (m) -> object : m.o.value, predicate : m.p.value

  predicates = linked.map (m) ->
    key : m.predicate
    aligned : alignPredicate(m.predicate)

  links = linked.map (m) ->
    subject : data.subject
    predicate : alignPredicate(m.predicate)
    object : m.object
    type : data.type

  console.log links
  predicates = _.uniq(predicates, false, (i) -> JSON.stringify(i))
  links = _.uniq(links, false, (i) -> JSON.stringify(i))
  push2namesParser
    predicates : predicates
    links : links
  store2neo links, done



