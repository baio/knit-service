async = require "async"
req = require "request"
amqp = require "../baio-amqp/amqp"

_opts = null
_parse = null

#send to amqp queue
push2Amqp = (level, urls) ->
  if urls and urls.length
    for url in urls
      amqp.pub _opts.amqp.queue, level : level, url : url

#make request
request = (url, done) ->
  #prepare request url
  url = "http://" + url if ! url.match /https?:\/\//
  req
    url : url
    method : "get"
    , done

requestAndParse = (level, url, done) ->
  #here make request, send repsonse body to _opts.parse, push urls returned from parser
  async.waterfall [
    (ck) ->
      request url, ck
    (resp, body, ck) ->
      _parse level, body, ck
  ], done


parseLevel = (level, url, done) ->
  _done = (err, links) ->
    if !err
      push2Amqp level + 1, links
    done err, links
  if url
    requestAndParse level, url, _done
  else
    #the vey first parse
    _parse level, null, _done

start = (opts, parse, done) ->
  _opts = opts
  _parse = parse
  amqp.setConfig opts.amqp.config
  amqp.connect ->
    amqp.sub {
      queue : opts.amqp.queue
      onPop: (data, ack) ->
        parseLevel data.level, data.url, (err) ->
          if !err
            ack()
    }
      , (err) ->
        done err
        if !err
          parseLevel -1, null, ->

exports.start = start
