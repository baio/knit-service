async = require "async"
req = require "request"
amqp = require "../baio-amqp/amqp"
log = require "./logs"

_opts = null
_parse = null

#send to amqp queue
push2Amqp = (level, urls) ->
  if urls and urls.length
    for url in urls
      log.write log.LOG_CODE_AMQP_PUSH, {level : level, url : url}
      amqp.pub _opts.amqp.queue, level : level, url : url

#make request
request = (url, done) ->

  if typeof url == "object"
    opts = url.request
  else
    opts =
      url : "http://" + url if ! url.match /https?:\/\//
      method : "get"
  log.write log.LOG_CODE_REQ, opts
  req opts, done

requestAndParse = (level, url, done) ->
  #here make request, send repsonse body to _opts.parse, push urls returned from parser
  async.waterfall [
    (ck) ->
      request url, ck
    (resp, body, ck) ->
      log.write log.LOG_CODE_REQ_RESP, body
      if typeof url == "object"
        data = url.data
      _parse level, body, data, ck
  ], done

parseLevel = (level, url, done) ->
  _done = (err, links) ->
    if !err
      push2Amqp level + 1, links
    done err, links
  log.write log.LOG_CODE_PARSE_LEVEL, level : level, url : url
  if url
    requestAndParse level, url, _done
  else
    #the vey first parse
    _parse level, null, null, _done

start = (opts, parse, done) ->
  _opts = opts
  _parse = parse
  amqp.setConfig opts.amqp.config
  log.setOpts opts.log
  amqp.connect ->
    amqp.sub {
      queue : opts.amqp.queue
      onPop: (data, ack) ->
        log.write log.LOG_CODE_AMQP_ON_POP, data
        parseLevel data.level, data.url, (err) ->
          if !err
            ack()
    }
      , (err) ->
        log.write log.LOG_CODE_AMQP_CONNECT, err
        done err
        if !err
          parseLevel -1, null, ->

exports.start = start
