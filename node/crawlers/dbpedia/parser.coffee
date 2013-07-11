_ = require "underscore"
inflect = require "underscore.inflections"
neo = require "../../baio-neo4j/neo4j"

neo.setConfig uri: process.env.NEO4J_URI

alignPredicate = (predicate) ->

  #get latest item in path, remove (es?), make singular
  p = "#{predicate.toLowerCase().match(/^.*\/(.*)$/)[1]}"
  p = inflect.singularize p
  "da:" + p

store2neo = (links, done) ->

  if links.length == 0
    done(null, [])
    return

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

  nodesSubj = links.map((l) -> node: l.subject, type: _getNodeType(l, true))
  nodesObj = links.map((l) -> node: l.object, type: _getNodeType(l, false))
  nodes = nodesSubj.concat nodesObj

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

  links = linked.map (m) ->
    subject : data.subject
    predicate : alignPredicate(m.predicate)
    object : m.object
    type : data.type

  links = _.uniq(links)

  store2neo links, done



