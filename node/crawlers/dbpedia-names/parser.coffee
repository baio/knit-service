_ = require "underscore"
neo = require "../../baio-neo4j/neo4j"

neo.setConfig uri: process.env.NEO4J_URI

exports.parseNames = (body, type, done) ->
  done null, []

exports.parseNodes = (pediaJson) ->
  null
