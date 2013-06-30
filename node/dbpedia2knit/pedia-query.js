// Generated by CoffeeScript 1.6.2
(function() {
  var req;

  req = require("request");

  module.exports = function(uri, query, done) {
    var data;

    data = {
      "default-graph-uri": "http://dbpedia.org",
      "query": query,
      "format": "application/sparql-results+json",
      "timeout": 30000
    };
    return req.get({
      uri: uri,
      qs: data
    }, function(err, data) {
      if (!err) {
        return done(null, JSON.parse(data.body).results.bindings);
      } else {
        return done(err);
      }
    });
  };

}).call(this);

/*
//@ sourceMappingURL=pedia-query.map
*/