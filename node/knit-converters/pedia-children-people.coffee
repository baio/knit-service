_q = require "./pedia-query"

people_query = """
             select distinct ?o, ?p
             where {
             <{0}> ?p ?o.
             ?o a dbpedia-owl:Person.
             }
             """

parse = (s, bindings) ->
  bindings.map (b) -> subject: s, predicator: b.p.value, object: b.o.value

module.exports = (uri, s, done) ->
  q = people_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse s, b
      #console.log d
    done err, d


