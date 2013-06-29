_q_iter = require "./pedia-iter"
_q_person_name = require "./pedia-person-name"
should = require "should"

_SPARQL_URI = "http://dbpedia.org/sparql"

getDimonName = ->
  _q_person_name _SPARQL_URI, "http://dbpedia.org/resource/Dmitry_Medvedev", (err, data) ->
    should.not.exist err
    should.exist data

iter = ->
  _q_iter (err) ->
    should.not.exist err

iter()
#getDimonName()

