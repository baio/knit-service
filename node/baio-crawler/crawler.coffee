async = require "async"
req = require "request"
amqp = require "./../../../node/baio-crawler/amqp"

_opts = null
_parse = null

#send to amqp queue
push = (level, urls) ->
  if urls and urls.length
    for url in urls
      amqp.pub _opts.amqp.queue, level : level, url : url

#make request
request = (url, done) ->
  #prepare request url
  url = "http://" + url if ! /https?:\/\//.match url
  req
    url : url
    method : "get"
    , done

onPop = (level, url, done) ->
  #here make request, send repsonse body to _opts.parse, push urls returned from parser
  async.waterfall [
    (ck) ->
      request url, ck
    (resp, ck) ->
      level = -1
      body = ""
      _parse level, body, ck
  ], done

start = (opts, parse) ->
  _opts = opts
  _parse = parse
  amqp.setConfig opts.amqp.config
  amqp.connect ->
    amqp.sub {
      queue : opts.amqp.queue
      onPop: (data, ack) ->
        level = data.level
        url = data.url
        onPop level, url, (err, links) ->
          if !err
            push level + 1, links
          ack()
    }
      , (err) ->
        console.log err, "subscribed"

  #_opts.parse 0, undefined, push

exports = start

start  amqp :
        config :
          url : "amqp://localhost"
        queue : "baio-crawler"
      , (level, body, done) ->
          console.log level, body
          done null

