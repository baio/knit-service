// Generated by CoffeeScript 1.6.2
/*
require('nodetime').profile
  accountKey: process.env.NODETIME_KEY,
  appName: 'dbpedia-craw'
*/


(function() {
  var craw, crawOpts, getQueryData, onPop, parser, queries, _opts;

  craw = require("../../baio-crawler/crawler");

  queries = require("./queries");

  parser = require("./parser");

  _opts = null;

  getQueryData = function(query, level, data) {
    return {
      "request": {
        "uri": "http://dbpedia.org/sparql",
        "method": "get",
        "qs": {
          "default-graph-uri": "http://dbpedia.org",
          "query": query,
          "format": "application/sparql-results+json",
          "timeout": 30000
        }
      },
      "data": data,
      "level": level
    };
  };

  onPop = function(level, body, data, done) {
    var binding, bindings, ex, j, offset, q, _i, _len;

    try {
      q = [];
      if (level === -1) {
        q.push(getQueryData(_opts.query(0), 0, {
          offset: 0,
          type: "" + _opts.name + "_list"
        }));
        return done(null, q);
      } else {
        j = JSON.parse(body);
        if (data.type === ("" + _opts.name + "_list")) {
          bindings = parser.parseBindings(j);
          offset = data.offset + 100;
          for (_i = 0, _len = bindings.length; _i < _len; _i++) {
            binding = bindings[_i];
            q.push(getQueryData(queries.subjectPersonLinks.replace("{0}", binding), 1, {
              subject: binding,
              type: "" + _opts.name + "_person"
            }));
            q.push(getQueryData(queries.subjectOrgLinks.replace("{0}", binding), 1, {
              subject: binding,
              type: "" + _opts.name + "_org"
            }));
          }
          q.push(getQueryData(_opts.query(offset), 0, {
            offset: offset,
            type: "" + _opts.name + "_list"
          }));
          return done(null, q);
        } else if (data.type === ("" + _opts.name + "_person") || data.type === ("" + _opts.name + "_org")) {
          return parser.parseLinks(j, data, function(err) {
            return done(err, q);
          });
        }
      }
    } catch (_error) {
      ex = _error;
      return done(ex);
    }
  };

  crawOpts = {
    amqp: {
      config: {
        url: process.env.AMQP_URI,
        prefetchCount: parseInt(process.env.AMQP_PREFETCH_COUNT)
      },
      queue: null
    },
    slaveLevel: parseInt(process.env.CRAWLER_SLAVE_LEVEL),
    skipInitial: {
      name: process.env.APP_NAME,
      val: process.env.CRAWLER_SKIP_INITIAL === "true" ? true : process.env.CRAWLER_SKIP_INITIAL === "false" ? void 0 : null
    },
    beforeQuery: function(opts) {
      var i, s, str, _i, _len, _ref;

      str = "";
      _ref = opts.qs.query;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        s = _ref[i];
        if (s === "'") {
          if (opts.qs.query[i - 1] === '(' || opts.qs.query[i + 1] === ')') {
            str += "'";
          } else {
            str += "\\'";
          }
        } else {
          str += s;
        }
      }
      return opts.qs.query = str.replace(/<([^>]*)>/g, "`iri('$1')`");
    },
    log: {
      loggly: {
        level: parseInt(process.env.CRAWLER_LOG_LEVEL_LOGGLY),
        domain: process.env.LOGGLY_DOMAIN,
        username: process.env.LOGGLY_USERNAME,
        password: process.env.LOGGLY_PASSWORD,
        input: process.env.APP_NAME
      },
      console: {
        level: parseInt(process.env.CRAWLER_LOG_LEVEL_CONSOLE)
      }
    }
  };

  exports.start = function(opts, done) {
    _opts = opts;
    crawOpts.amqp.queue = process.env.APP_NAME;
    return craw.start(crawOpts, onPop, done);
  };

}).call(this);

/*
//@ sourceMappingURL=dbpedia.map
*/
