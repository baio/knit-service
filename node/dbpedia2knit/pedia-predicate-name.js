// Generated by CoffeeScript 1.6.2
(function() {
  var name_query, parse, _q;

  _q = require("./pedia-query");

  name_query = "select distinct ?o\nwhere {\n<{0}> rdfs:label ?o.\n}";

  parse = function(s, bindings) {
    return bindings.map(function(m) {
      return {
        id: s,
        name: m.o.value.toLowerCase(),
        lang: m.o["xml:lang"]
      };
    });
  };

  module.exports = function(uri, s, done) {
    var q;

    q = name_query.replace("{0}", s);
    return _q(uri, q, function(err, b) {
      var d;

      if (!err) {
        d = parse(s, b);
      }
      return done(err, d);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=pedia-predicate-name.map
*/
