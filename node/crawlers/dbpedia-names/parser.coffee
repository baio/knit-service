queries = require "./queries"
es = require "../../baio-es/es"
_ = require "underscore"

_alignName = (name) ->
  name.replace(/^\s+|\s+$/g, '').toLowerCase()

exports.parseNames = (body, type, done) ->
  names = []
  body.results.bindings.forEach (m) ->
    if m.given_name and m.sur_name
      names.push key : m.s.value,  val : _alignName(m.given_name.value + " " + m.sur_name.value), lang : m.given_name["xml:lang"]
    if m.name
      names.push key : m.s.value,  val : _alignName(m.name.value), lang : m.name["xml:lang"]
    if m.label
      names.push key : m.s.value,  val : _alignName(m.label.value), lang : m.label["xml:lang"]
    if m.foaf_name
      names.push key : m.s.value,  val : _alignName(m.foaf_name.value), lang : m.foaf_name["xml:lang"]
  names = _.uniq names, false, (i) -> i.val + i.lang
  docs = names.map (m) -> _id : m.val, _type : "dbpedia", val : m.val, lang : m.lang, key : m.key
  es.bulk process.env.ES_URI, "#{type}-names", docs, done

exports.parseKeys = (data, done) ->
  predicates = data.predicates.map((m) ->
    val = m.aligned.replace(/^da:/, '')
    key : m.key, val : val, lang : "en", _id : val, _type : "dbpedia")
  nodes = data.nodes
  res =
    people : nodes.filter((f) -> f.type == "person").map((m) -> decodeURIComponent(m.node))
    orgs : nodes.filter((f) -> f.type == "org").map((m) -> decodeURIComponent(m.node))
  es.bulk process.env.ES_URI, "predicate-names", predicates, (err) ->
    done err, res

