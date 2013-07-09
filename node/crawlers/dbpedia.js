// Generated by CoffeeScript 1.6.2
(function() {
  var craw, getQueryData, onPop, opts, parser, queries;

  craw = require("../baio-crawler/crawler");

  queries = require("./queries");

  parser = require("./parser");

  getQueryData = function(query, type, offset) {
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
      "data": {
        "type": type,
        "offset": offset
      }
    };
  };

  onPop = function(level, body, data, done) {
    var j, offset, people, person, q, _i, _len;

    q = [];
    if (level === -1) {
      q.push(getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", 0), "people_list", 0));
    } else {
      j = JSON.parse(body);
      people = parser.parsePeople(j);
      if (data.type === "people_list") {
        offset = data.offset + 100;
        for (_i = 0, _len = people.length; _i < _len; _i++) {
          person = people[_i];
          q.push(getQueryData(queries.subjectPersonLinks.replace("{0}", person), "links"));
          q.push(getQueryData(queries.subjectOrgLinks.replace("{0}", person), "links"));
        }
        q.push(getQueryData(queries.peopleReq.replace("{0}", 100).replace("{1}", offset), "people_list", offset));
      } else if (data.type === "links") {
        parser.parseLinks(j);
      }
    }
    return done(null, q);
  };

  opts = {
    amqp: {
      config: {
        url: "amqp://localhost"
      },
      queue: "baio-crawler"
    },
    log: {
      level: 0,
      write: function(level, code, msg) {
        return console.log(level, code, msg);
      }
    }
  };

  craw.start(opts, onPop, function(err) {
    return console.log("started", err);
  });

}).call(this);

/*
//@ sourceMappingURL=dbpedia.map
*/
