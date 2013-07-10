// Generated by CoffeeScript 1.6.2
(function() {
  var _getLvl, _opts,
    _this = this;

  exports.LOG_LVL_HIGH = 1000;

  exports.LOG_LVL_MID = 500;

  exports.LOG_LVL_LOW = 0;

  exports.LOG_CODE_AMQP_CONNECT = "LOG_CODE_AMQP_CONNECT";

  exports.LOG_CODE_PARSER_ERROR = "LOG_CODE_PARSER_ERROR";

  exports.LOG_CODE_REQ_ERROR = "LOG_CODE_REQ_ERROR";

  exports.LOG_CODE_AMQP_PUSH = "LOG_CODE_AMQP_PUSH";

  exports.LOG_CODE_AMQP_ON_POP = "LOG_CODE_AMQP_ON_POP";

  exports.LOG_CODE_REQ = "LOG_CODE_REQ";

  exports.LOG_CODE_REQ_RESP = "LOG_CODE_REQ_RESP";

  exports.LOG_CODE_PARSE_LEVEL = "LOG_CODE_PARSE_LEVEL";

  _opts = null;

  _getLvl = function(code) {
    switch (code) {
      case exports.LOG_CODE_AMQP_CONNECT:
        return exports.LOG_LVL_HIGH;
      case exports.LOG_CODE_PARSER_ERROR:
        return exports.LOG_LVL_HIGH;
      case exports.LOG_CODE_REQ_ERROR:
        return exports.LOG_LVL_HIGH;
      case exports.LOG_CODE_AMQP_PUSH:
        return exports.LOG_LVL_MID;
      case exports.LOG_CODE_AMQP_ON_POP:
        return exports.LOG_LVL_MID;
      case exports.LOG_CODE_REQ:
        return exports.LOG_LVL_LOW;
      case exports.LOG_CODE_REQ_RESP:
        return exports.LOG_LVL_LOW;
      case exports.LOG_CODE_PARSE_LEVEL:
        return exports.LOG_LVL_LOW;
    }
  };

  exports.setOpts = function(opts) {
    return _opts = opts;
  };

  exports.write = function(code, msg) {
    if (_opts) {
      return exports.writeLvl(_getLvl(code), code, msg);
    }
  };

  exports.writeLvl = function(lvl, code, msg) {
    if (_opts && _opts.level <= lvl) {
      return _opts.write(lvl, code, msg);
    }
  };

}).call(this);

/*
//@ sourceMappingURL=logs.map
*/
