request = require("./request")
cache = require "./cache/redis"
async = require "async"
es = require "event-stream"

#Caching strategy
#GET: If graph not found in cache, read from links service and then put it into the cache (update isYours before)
#PUT, PATCH, DELETE - remove graph from cache, if action succesfull

_del = (ref) ->
  es.join((err) ->
    console.log "delete graph from cache : " + err
    if !err
      console.log ref
      cache.del "graph", ref
  )

exports.get = (req, res) ->
  ref = if req.query then req.query.graph else null
  async.waterfall [
    (ck) ->
      if req.query.context != "data"
        cache.get "graph", ref, ck
      else
        ck null, null
    (r, ck) ->
      if !r
        request.req(req, res, "graphs", true, es.join(ck))
      else
        console.log "graph found in cache it's allrigth!"
        res.writeHead(200, { 'Content-Type': 'application/json' })
        r = JSON.parse(r)
        r.isYours = req.user and req.user.name == r.owner
        res.write JSON.stringify(r)
        #res.write r
        res.end()
        ck null, null
    ], (err, data) ->
        if !err and data and req.query.context != "data"
          cache.set "graph", ref, data

exports.post = (req, res) ->
  request.req(req, res, "graphs", true)

exports.put = (req, res) ->
  request.req(req, res, "graphs", true, _del(req.body.id))

exports.patch = (req, res) ->
  request.req(req, res, "graphs", true, _del(req.body.id))

exports.delete = (req, res) ->
  request.req(req, res, "graphs", true, _del(req.body.id))
