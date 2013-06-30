async = require "async"
mongo = require "../baio-mongo/mongo"

_readAndConvert = (coll, done) ->
  coll.find().each (err, doc) ->
    if !err
      if doc
        console.log doc
      else
        done()

convert = (done) ->

  mongo.setConfig uri : process.env.MONGO_URI
  async.waterfall [
    (ck) ->
      mongo.open "contribs", ck
    (coll, ck) ->
      _readAndConvert coll, (err) ->
        ck err, coll
    ], (err, coll) ->
      if coll
        mongo.close coll
      done err

convert (err) ->
  console.log err

