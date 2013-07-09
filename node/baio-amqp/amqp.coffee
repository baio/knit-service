async = require "async"
amqp = require "amqp"

_config = null
_con = null
_exch = null
_queues = {}

exports.setConfig = (config) ->
  _config = config

exports.connect = (done) ->
  if !_con
    _con = amqp.createConnection _config
    _con.on "ready", ->
      _con.exchange "", durable : true, autoDelete: false, (exch) ->
        _exch = exch
        done null
    _con.on "error", (exception) ->
      console.log exception
      #done exception

exports.pub = (queue, data) ->
  _exch.publish queue, data, deliveryMode : 2, contentType : "application/json"

exports.sub = (opts, done) ->
  connectQueue opts.queue, (err, q) ->
      if !err
        #Receive messages
        q.subscribe ack : true, prefetchCount : 1, (message) ->
          opts.onPop message, -> q.shift()
      done err

connectQueue = (queue, done) ->
  #Use the default 'amq.topic' exchange
  _con.queue queue, durable : true, autoDelete: false, (q) ->
    #Catch all messages
    q.bind "#"
    done null, q


