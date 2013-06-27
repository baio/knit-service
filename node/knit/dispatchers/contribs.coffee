request = require("./request")
cache = require "./cache/redis"
es = require "event-stream"

_del = ->
  es.join((err, data) ->
    console.log "delete graph from cache : " + err
    if !err
      j = JSON.parse(data)
      console.log j
      cache.del "graph", j.graphs
  )

exports.get = (req, res) ->
  request.req(req, res, "contribs")

exports.post = (req, res) ->
  request.req(req, res, "contribs")

exports.put = (req, res) ->
  request.req(req, res, "contribs")

exports.patch = (req, res) ->
  request.req(req, res, "contribs", false, _del())

exports.delete = (req, res) ->
  request.req(req, res, "contribs", false, _del())

exports.copy = (req, res) ->
  request.req(req, res, "contribs")