async = require "async"
req = require "request"
amqp = require "../baio-amqp/amqp"
log = require "./logs"

_opts = null
_parse = null

doneLog = (errCode, done) ->
  (err, arg1, arg2) ->
    if err
      log.write errCode, err
    done err, arg1, arg2

#send to amqp queue
push2Amqp = (level, urls) ->
  if urls and urls.length
    for url in urls
      level = url.level if url.level
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
  req opts, doneLog(log.LOG_CODE_REQ_ERROR, done)


requestAndParse = (level, url, done) ->
  #here make request, send repsonse body to _opts.parse, push urls returned from parser
  async.waterfall [
    (ck) ->
      request url, ck
    (resp, body, ck) ->
      log.write log.LOG_CODE_REQ_RESP, body
      if typeof url == "object"
        data = url.data
        _parse level, body, data, doneLog(log.LOG_CODE_PARSER_ERROR, ck)
  ], done

parseLevel = (level, url, done) ->
  _done = (err, links) ->
    if !err and _opts.slaveLevel == -1
      push2Amqp level + 1, links
    done err, links
  log.write log.LOG_CODE_PARSE_LEVEL, level : level, url : url
  if level != -1
    requestAndParse level, url, _done
  else
    _parse level, null, null, doneLog(log.LOG_CODE_PARSER_ERROR, _done)


start = (opts, parse, done) ->
  _opts = opts
  _opts.slaveLevel ?= -1
  _parse = parse
  amqp.setConfig opts.amqp.config
  log.setOpts opts.log
  amqp.connect ->
    amqp.sub {
      queue : opts.amqp.queue
      onPop: (data, ack) ->
        if _opts.slaveLevel == -1 or data.level == _opts.slaveLevel
          log.write log.LOG_CODE_AMQP_ON_POP, data
          parseLevel data.level, data.url, (err) ->
            ack(err)
        else
          #slave mode, ignore messages not from the slave level
          ack(true)
    }
      , (err) ->
        log.write log.LOG_CODE_AMQP_CONNECT, {err : err, opts, opts : _opts}
        done err
        if !err
          if _opts.slaveLevel == -1
            parseLevel -1, null, ->

exports.start = start
