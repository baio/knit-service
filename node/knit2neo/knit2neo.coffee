async = require "async"
mongo = require "../baio-mongo/mongo"
es = require "../baio-es/es"
neo = require "../baio-neo4j/neo4j"
undesrcore = require "underscore.inflections"

_ES_URI = process.env.ES_URI
_LANGS = ["ru", "en"]

neo.setConfig uri: process.env.NEO4J_URI

_isUri = (name) ->
  if name.match(/^\w+:.*$/) then true else false

_getIndex = (name, type, val, done) ->
  if _isUri val
    q =
      query:
        term:
          uri: val
  else
    q =
      query:
        query_string:
          query: val

  es.query _ES_URI, name, q, (err, data) ->
    if !err and data and data.length
      res =
        uri: data[0].uri
        names: data.map (m) ->
          name: m.name, lang: m.lang
    else
      res =
        uri: val
        names: [
          name: val, lang: "en"
        ]
    done null, res

_getLinkName = (name, dom, done) ->
  _getIndex "predicates", dom, name, (err, data) ->
    if !err
      data.uri = _alignPredicate(data.uri)
    done err, data

_getNodeName = (name, dom, type, done) ->
  _getIndex "#{type}-names", dom, name, done

_alignPredicate = (predicate) ->
  if _isUri(predicate)
    #get latest item in path, remove (es?), make singular
    p = "#{predicate.toLowerCase().match(/^.*\/(.*)$/)[1]}"
    p = undesrcore.singularize p
    "da:" + p
  else
    predicate

_mapLink = (item, done) ->
  async.parallel [
    (ck) ->
      _getLinkName(item.predicate, item.dom, ck)
    (ck) ->
      _getNodeName(item.subject, item.dom, (if (item.type == "po" or item.type == "pp") then "person" else "org"), ck)
    (ck) ->
      _getNodeName(item.object, item.dom, (if (item.type == "op" or item.type == "pp") then "person" else "org"), ck)
  ], (err, results) ->
    res =
      predicate: results[0]
      subject: results[1]
      object: results[2]
      url: item.url
      contrib: item._id.toString()
    done null, res

_groupLinks = (links) ->
  res = []
  for link in links
    r = res.filter((f) ->
      f.predicate.uri == link.predicate.uri and f.subject.uri == link.subject.uri and f.object.uri == link.object.uri)[0]
    if !r
      r = link
      r.contribs = []
      r.urls = []
      res.push r
    if r.urls.indexOf(link.url) == -1
      r.urls.push link.url
    if r.contribs.indexOf(link.contrib) == -1
      r.contribs.push link.contrib
  res

_updateLinks = (links, done) ->

  nodes = []

  i = 0
  for link in links
    link.nodes = [i, i+1]
    nodes.push link.object
    nodes.push link.subject
    i += 2

  neo.createBatch
    nodeOpts:
      index: "wiki"
      keyValue: (m) -> uri : m.uri
      properties: (m) -> names : m.names.map (m) -> m.lang + ":" + m.name
    nodes: nodes
    relOpts:
      type: (m) ->m.predicate.uri
      nodesIndexes: (m) -> m.nodes
      properties: (m, n) ->
        r =
          names : m.names.map (m) -> m.lang + ":" + m.name
          urls : m.urls
          contribs : m.contribs
        for u in n.data?.urls
          if r.urls.indexOf(u) == -1 then r.urls.push u
        for u in n.data?.contribs
          if r.contribs.indexOf(u) == -1 then r.contribs.push u
        r
    rels : links
    , done

_map = (items, done) ->
  async.map items, ((i, ck) ->
    _mapLink i, ck), (err, links) ->
      links = _groupLinks links
      _updateLinks links, done

_readAndConvert = (coll, done) ->
  f = true
  cursor = coll.find()
  async.whilst(
    ->
      f
    (ck) ->
      cursor.nextObject (err, doc) ->
        if !err
          if doc
            _map doc.items, ck
          else
            f = false
            ck()
        else
          ck()
    done)

convert = (done) ->
  mongo.setConfig uri: process.env.MONGO_URI
  async.waterfall [
    (ck) ->
      mongo.open "contribs", ck
    (coll, ck) ->
      _readAndConvert coll, (err) ->
        ck err, coll
  ], (err, coll) ->
    if coll
      mongo.close coll
    done err

convert (err) ->
  console.log err
