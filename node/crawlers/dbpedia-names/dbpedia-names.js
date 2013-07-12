// Generated by CoffeeScript 1.6.2
/*
require('nodetime').profile
  accountKey: process.env.NODETIME_KEY,
  appName: 'dbpedia-craw'
*/


(function() {
  var craw, crawOpts, getNeoQueryData, getPediaQueryData, neo, neoQuery, onPop, parser, queries;

  craw = require("../../baio-crawler/crawler");

  queries = require("./queries");

  parser = require("./parser");

  neo = require("../../baio-neo4j/neo4j");

  getNeoQueryData = function(query, level, data) {
    return {
      "request": query,
      "data": data,
      "level": level
    };
  };

  getPediaQueryData = function(query, level, data) {
    return {
      "request": query,
      "data": data,
      "level": level
    };
  };

  neoQuery = function(opts, done) {
    return neo.query(opts, null, done);
  };

  /*
    Levels :
    1. -1, query to neo
    2. 0 - parse from pedia
    3. 1 - query to pedia
  */


  onPop = function(level, body, data, done) {
    var ex, j, node, offset, q;

    try {
      offset = level === -1 ? 0 : data.offset;
      q = [];
      if (level === -1 || level === 0) {
        q.push(getNeoQueryData("start n=node(*) return n skip " + offset + " limit 1", 0, {
          offset: offset
        }));
        offset += 1;
        if (level === 0) {
          return parser.parseNames(body, data.type, done);
        } else {
          return done(null, q);
        }
      } else if (level === 1) {
        j = JSON.parse(body);
        if (j) {
          node = parser.parseNode(j);
          if (node.type === "perosn") {
            q.push(getPediaQueryData(queries.personNameReq.replace("{0}", node.value), 0, {
              type: "person",
              offset: offset
            }));
          } else if (node.type === "org") {
            q.push(getPediaQueryData(queries.personOrgReq.replace("{0}", node.value), 0, {
              type: "org",
              offset: offset
            }));
          }
        }
        return done(null, q);
      } else {
        throw "level out of range";
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
    },
    query: function(level) {
      if (level === -1 || level === 0) {
        return neoQuery;
      } else {
        return null;
      }
    }
  };

  exports.start = function(done) {
    crawOpts.amqp.queue = process.env.APP_NAME;
    return craw.start(crawOpts, onPop, done);
  };

}).call(this);

/*
//@ sourceMappingURL=dbpedia-names.map
*/
