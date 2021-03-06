// Generated by CoffeeScript 1.6.2
(function() {
  var dbpedia, opts, queries;

  dbpedia = require("./dbpedia");

  queries = require("./queries");

  opts = {
    name: "org",
    query: function(offset) {
      return queries.orgsReq.replace("{0}", 100).replace("{1}", offset);
    }
  };

  exports.start = function(done) {
    return dbpedia.start(opts, done);
  };

}).call(this);

/*
//@ sourceMappingURL=orgs.map
*/
