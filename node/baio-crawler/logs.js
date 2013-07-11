// Generated by CoffeeScript 1.6.2
(function() {
  var appendWriter, async, consoleWriter, write, _getLvl, _writers,
    _this = this,
    __hasProp = {}.hasOwnProperty;

  async = require("async");

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

  _writers = [];

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

  consoleWriter = function(lvl, code, msg) {
    return console.log(lvl, code, msg);
  };

  appendWriter = function(writer) {
    return _writers.push(writer);
  };

  write = function(lvl, code, msg) {
    var wr, _i, _len, _results;

    _results = [];
    for (_i = 0, _len = _writers.length; _i < _len; _i++) {
      wr = _writers[_i];
      if (wr.level <= lvl) {
        _results.push(wr.write(lvl, code, msg));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  exports.setOpts = function(opts, done) {
    var prop, wrs;

    wrs = [];
    for (prop in opts) {
      if (!__hasProp.call(opts, prop)) continue;
      wrs.push(prop);
    }
    return async.map(wrs, function(name, ck) {
      if (name === "loggly") {
        return exports.getLoggly(opts[name], function(err, writer) {
          return ck(err, {
            name: name,
            write: writer,
            level: opts[name].level
          });
        });
      } else if (name === "console") {
        return ck(null, (opts[name] ? {
          name: name,
          write: consoleWriter,
          level: opts[name].level
        } : null));
      } else {
        return ck(null, {
          name: name,
          write: opts[name],
          level: 0
        });
      }
    }, function(err, results) {
      var r, _i, _len, _ref;

      if (!err) {
        _ref = results.filter(function(f) {
          return f;
        });
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          appendWriter(r);
        }
      }
      return done(err);
    });
  };

  exports.write = function(code, msg) {
    return exports.writeLvl(_getLvl(code), code, msg);
  };

  exports.writeLvl = function(lvl, code, msg) {
    return write(lvl, code, msg);
  };

  exports.getLoggly = function(opts, done) {
    var client, config, loggly;

    loggly = require("loggly");
    config = {
      subdomain: opts.domain,
      auth: {
        username: opts.username,
        password: opts.password
      },
      json: true
    };
    client = loggly.createClient(config);
    return client.getInput(opts.input, function(err, input) {
      if (!err) {
        return done(err, function(lvl, code, msg) {
          return input.log({
            level: lvl,
            code: code,
            msg: msg
          });
        });
      } else {
        return done(err);
      }
    });
  };

}).call(this);

/*
//@ sourceMappingURL=logs.map
*/
