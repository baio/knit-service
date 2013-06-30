_q = require "./pedia-query"

name_query = """
             select distinct ?o
             where {
             <{0}> rdfs:label ?o.
             }
            """

parse = (s, bindings) ->

  bindings.map (m) ->
    name :  m.o.value.toLowerCase()
    lang :  m.o["xml:lang"]


module.exports = (uri, s, done) ->
  q = name_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse s, b
    done err, d


