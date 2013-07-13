_ = require "underscore"
neo = require "../../baio-neo4j/neo4j"
queries = require "./queries"
es = require "../../baio-es/es"

neo.setConfig uri: process.env.NEO4J_URI

_alignName = (name) ->
  name.replace(/^\s+|\s+$/g, '').toLowerCase()

exports.parseNames = (body, type, done) ->
  names = []
  body.results.bindings.forEach (m) ->
    if type == "person"
      names.push key : m.s.value,  val : _alignName(m.given_name.value + " " + m.sur_name.value), lang : m.given_name["xml:lang"]
    names.push key : m.s.value,  val : _alignName(m.name.value), lang : m.name["xml:lang"]
    names.push key : m.s.value,  val : _alignName(m.label.value), lang : m.label["xml:lang"]
    names.push key : m.s.value,  val : _alignName(m.foaf_name.value), lang : m.foaf_name["xml:lang"]
  names = _.uniq names, false, (i) -> i.val + i.lang
  docs = names.map (m) -> _id : m.val, _type : type, val : m.val, lang : m.lang, key : m.key
  es.bulk process.env.ES_URI, "#{type}-names", docs, done

exports.parseNode = (pediaJson) ->
  value : decodeURIComponent(pediaJson[0].n.data.uri), type : pediaJson[0].n.data.type
