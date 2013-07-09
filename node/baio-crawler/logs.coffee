exports.LOG_LVL_HIGH = 1000
exports.LOG_LVL_MID = 500
exports.LOG_LVL_LOW = 0

#high level
exports.LOG_CODE_AMQP_CONNECT = "LOG_CODE_AMQP_CONNECT"

#mid level
exports.LOG_CODE_AMQP_PUSH = "LOG_CODE_AMQP_PUSH"
exports.LOG_CODE_AMQP_ON_POP = "LOG_CODE_AMQP_ON_POP"

#low level
exports.LOG_CODE_REQ = "LOG_CODE_REQ"
exports.LOG_CODE_REQ_RESP = "LOG_CODE_REQ_RESP"
exports.LOG_CODE_PARSE_LEVEL = "LOG_CODE_PARSE_LEVEL"

_opts = null

_getLvl = (code) ->
  switch code
    when exports.LOG_CODE_AMQP_CONNECT then return exports.LOG_LVL_HIGH
    when exports.LOG_CODE_AMQP_PUSH then return exports.LOG_LVL_MID
    when exports.LOG_CODE_AMQP_ON_POP then return exports.LOG_LVL_MID
    when exports.LOG_CODE_REQ then return exports.LOG_LVL_LOW
    when exports.LOG_CODE_REQ_RESP then return exports.LOG_LVL_LOW
    when exports.LOG_CODE_PARSE_LEVEL then return exports.LOG_LVL_LOW

exports.setOpts = (opts) =>
  _opts = opts

exports.write = (code, msg) ->
  if _opts
    exports.writeLvl _getLvl(code), code, msg

exports.writeLvl = (lvl, code, msg) ->
  if _opts and _opts.level <= lvl
    _opts.write lvl, code, msg
