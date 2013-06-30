_q = require "./pedia-query"

name_query = """

             select distinct ?s, ?name, ?label, ?foaf_name
             where
             {
             ?s ?p ?o.
             optional { ?s dbpprop:name ?name }
             optional { ?s rdfs:label ?label }
             optional { ?s foaf:name ?foaf_name }
             optional { ?s dbpprop:nativeName ?native_name }
             FILTER (?s = <{0}>)
             }
            """


_lower_filter = (item) ->
  item.name = item.name.toLowerCase()

_lang_filter = (item) ->
  if item.name.match /^[\u0400-\u0450\s]+$/
    item.lang = "ru"

_get_unique = (items) ->
  res = []
  for item in items
    if !res.filter((f) -> f.name == item.name and f.lang == item.lang)[0]
      res.push item
  res

parse = (bindings) ->

  res = []

  for b in bindings

    if b.name
      res.push id : b.s.value, name : b.name.value, lang :  b.name["xml:lang"]

    if b.label
      res.push id : b.s.value, name : b.label.value, lang :  b.label["xml:lang"]

    if b.foaf_name
      res.push id : b.s.value, name : b.foaf_name.value, lang :  b.foaf_name["xml:lang"]

  res.map (m) ->
    _lower_filter m
    _lang_filter m

  _get_unique(res)

module.exports = (uri, s, done) ->
  q = name_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse b
    done err, d


