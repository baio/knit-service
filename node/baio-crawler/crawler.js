// Generated by CoffeeScript 1.6.2
(function() {
  var amqp, async, doneLog, isSkipInitial, log, parseData, parseLevel, push2Amqp, query, req, request, requestAndParse, skipInitialState, start, webQuery, _opts, _parse;

  async = require("async");

  req = require("request");

  amqp = require("../baio-amqp/amqp");

  log = require("./logs");

  skipInitialState = require("./skip-initial-state");

  _opts = null;

  _parse = null;

  doneLog = function(errCode, done) {
    return function(err, arg1) {
      if (err) {
        log.write(errCode, err);
      }
      return done(err, arg1);
    };
  };

  push2Amqp = function(level, urls) {
    var url, _i, _len, _results;

    if (urls && urls.length) {
      _results = [];
      for (_i = 0, _len = urls.length; _i < _len; _i++) {
        url = urls[_i];
        if (url.level !== void 0) {
          level = url.level;
        }
        log.write(log.LOG_CODE_AMQP_PUSH, {
          level: level,
          url: url
        });
        _results.push(amqp.pub(_opts.amqp.queue, {
          level: level,
          url: url
        }));
      }
      return _results;
    }
  };

  request = function(url, level, done) {
    var opts;

    if (typeof url === "object") {
      opts = url.request;
    } else {
      opts = {
        url: !url.match(/https?:\/\//) ? "http://" + url : void 0,
        method: "get"
      };
    }
    log.write(log.LOG_CODE_REQ, opts);
    return query(opts, level, doneLog(log.LOG_CODE_REQ_ERROR, done));
  };

  webQuery = function(opts, done) {
    return req(opts, function(err, resp, body) {
      return done(err, body);
    });
  };

  query = function(opts, level, done) {
    var q;

    q = typeof _opts.query === "function" ? _opts.query(level) : void 0;
    if (q == null) {
      q = webQuery;
    }
    return q(opts, done);
  };

  isSkipInitial = function() {
    var wasLocked;

    if (_opts.skipInitial.val === null) {
      wasLocked = skipInitialState.lock(_opts.skipInitial.name);
      return wasLocked;
    } else {
      skipInitialState.unlock(_opts.skipInitial.name);
      return _opts.skipInitial.val;
    }
  };

  requestAndParse = function(level, url, done) {
    return async.waterfall([
      function(ck) {
        return request(url, level, ck);
      }, function(body, ck) {
        var data;

        log.write(log.LOG_CODE_REQ_RESP, body);
        if (typeof url === "object") {
          data = url.data;
        }
        return _parse(level, body, data, doneLog(log.LOG_CODE_PARSER_ERROR, ck));
      }
    ], done);
  };

  parseLevel = function(level, url, done) {
    var _done;

    _done = function(err, links) {
      if (!err && _opts.slaveLevel === -1) {
        push2Amqp(level + 1, links);
      }
      return done(err, links);
    };
    log.write(log.LOG_CODE_PARSE_LEVEL, {
      level: level,
      url: url
    });
    if (level !== -1) {
      return requestAndParse(level, url, _done);
    } else {
      if (!isSkipInitial()) {
        return _parse(level, null, null, doneLog(log.LOG_CODE_PARSER_ERROR, _done));
      } else {
        return _done();
      }
    }
  };

  parseData = function(data, done) {
    var _done;

    _done = function(err, links) {
      if (!err && _opts.slaveLevel === -1) {
        push2Amqp(null, links);
      }
      return done(err, links);
    };
    log.write(log.LOG_CODE_PARSE_DATA, {
      data: data
    });
    return _parse(null, null, data, doneLog(log.LOG_CODE_PARSER_ERROR, _done));
  };

  start = function(opts, parse, done) {
    var _ref;

    _opts = opts;
    if ((_ref = _opts.slaveLevel) == null) {
      _opts.slaveLevel = -1;
    }
    _parse = parse;
    amqp.setConfig(opts.amqp.config);
    return log.setOpts(opts.log, function(err) {
      if (!err) {
        return amqp.connect(function() {
          return amqp.sub({
            queue: opts.amqp.queue,
            onPop: function(data, ack) {
              if (_opts.slaveLevel === -1 || data.level === _opts.slaveLevel) {
                log.write(log.LOG_CODE_AMQP_ON_POP, data);
                if (data.level !== void 0) {
                  return parseLevel(data.level, data.url, ack);
                } else {
                  return parseData(data, ack);
                }
              } else {
                return ack(true);
              }
            }
          }, function(err) {
            log.write(log.LOG_CODE_AMQP_CONNECT, {
              err: err,
              opts: opts,
              opts: JSON.stringify(_opts)
            });
            done(err);
            if (!err) {
              if (_opts.slaveLevel === -1) {
                return parseLevel(-1, null, function() {});
              }
            }
          });
        });
      } else {
        throw err;
      }
    });
  };

  exports.start = start;

}).call(this);

/*
//@ sourceMappingURL=crawler.map
*/
