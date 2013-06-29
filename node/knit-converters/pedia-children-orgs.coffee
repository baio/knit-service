_q = require "./pedia-query"

orgs_query = """
               select ?p, ?o
               where {
               <{0}> ?p ?o.
               ?p rdfs:range ?r.
               ?r rdfs:subClassOf dbpedia-owl:Organisation.
               }
             """

parse = (s, bindings) ->
  bindings.map (b) -> subject: s, predicator: b.p.value, object: b.o.value

module.exports = (uri, s, done) ->
  q = orgs_query.replace("{0}", s)
  _q uri, q, (err, b) ->
    if !err
      d = parse s, b
      #console.log d
    done err, d


