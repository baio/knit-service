if process.env.CACHE_DISABLED != "true"
  redis = require "redis"
  client = redis.createClient(process.env.REDIS_PORT, process.env.REDIS_HOST)
  client.auth process.env.REDIS_PASSWORD, (err) ->
    console.log "Redis connect : " + err

_default_graph = "518b989739ed9714289d0bc1"

_checkCacheEnabled = (done) ->
  if process.env.CACHE_DISABLED == "true"
    if done then done(null, null)
    return false
  else
    return true

_get_key = (type, key) ->
  if !key
    key = _default_graph
  type + "_" + key

get = (type, key, done) ->
  if ! _checkCacheEnabled(done) then return
  client.get _get_key(type, key), (err, reply) ->
    done err, reply

set = (type, key, data) ->
  if ! _checkCacheEnabled() then return
  client.set _get_key(type, key), data, redis.print

del = (type, key) ->
  if ! _checkCacheEnabled() then return
  key = [key] if  !Array.isArray key
  key = key.map((k) -> _get_key(type, k))
  client.del key, redis.print

getJSON = (type, key, done) ->
  get type, key, (err, reply) ->
    done err, (if !err and reply then JSON.parse reply)

setJSON = (type, key, data) ->
  set type, key, JSON.stringify(data)

exports.get = get
exports.set = set
exports.del = del
exports.getJSON = getJSON
exports.setJSON = setJSON
