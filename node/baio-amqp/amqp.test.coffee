amqp = require "./amqp"

amqpConnect = (done) ->
  amqp.setConfig uri : "amqp://localhost"
  amqp.connect (err) ->
    console.log "connect", err
    done err

amqpSub = (done)->
  amqpConnect ->
    amqp.sub {
      queue: "test"
      onPop: (msg, ack) ->
        console.log "onSub", msg
        ack()
      }, done

amqpPub = (done) ->
  amqpConnect ->
    for i in [0..5]
      amqp.pub "test", level : 0
    done()


amqpPub5times = (done) ->
  amqpConnect ->
    for i in [0..4]
      amqp.pub "test", level : 0
    done()


amqpSubOncePub5times = (done) ->
  amqpConnect ->
    amqp.sub {
      queue: "test"
      onPop: (msg, ack) ->
        console.log "onSub", msg
        ack()
    }, (err) ->
      if !err
        for i in [0..4]
          amqp.pub "test", level : 0
        done err

amqpSubOncePub5timesThenPubFromSub = (done) ->
  amqpConnect ->
    amqp.sub {
      queue: "test"
      onPop: (msg, ack) ->
        console.log "onSub", msg
        if msg.level == 0
          amqp.pub "test", level : 1
        ack()
    }, (err) ->
      if !err
        for i in [0..4]
          amqp.pub "test", level : 0
        done err

amqpSubPubNoAckFirstTime = (done) ->
  _f = true
  amqpConnect ->
    amqp.sub {
      queue: "test"
      onPop: (msg, ack) ->
        console.log "onPop", msg
        ack _f
        _f = false
    }, (err) ->
        amqp.pub "test", level : 0
        done err


###
amqpPub ->

amqpSub (err) ->
  console.log "subscribed", err

amqpPub5times ->
  console.log "published 5 times"

amqpSub (err) ->
  console.log "subscribed", err

###

amqpSubOncePub5times (err) ->
  console.log "amqpSubOncePub5times", err

###
amqpSubOncePub5timesThenPubFromSub (err) ->
  console.log "amqpSubOncePub5timesThenPubFromSub", err



amqpSubPubNoAckFirstTime ->

###