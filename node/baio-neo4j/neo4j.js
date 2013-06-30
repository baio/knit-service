// Generated by CoffeeScript 1.6.2
(function() {
  var async, req, _config;

  async = require("async");

  req = require("request");

  _config = null;

  exports.setConfig = function(config) {
    return _config = config;
  };

  exports.query = function(query, params, done) {
    var data;

    data = {
      query: query,
      params: params
    };
    return req({
      uri: _config.uri,
      method: "get",
      body: JSON.stringify(data),
      headers: {
        'content-type': 'application/json',
        'X-Stream': true
      }
    }, function(err, res) {
      return done(err, res.body);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=neo4j.map
*/
