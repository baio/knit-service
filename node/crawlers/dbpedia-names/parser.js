// Generated by CoffeeScript 1.6.2
(function() {
  var es, neo, queries, _, _alignName;

  _ = require("underscore");

  neo = require("../../baio-neo4j/neo4j");

  queries = require("./queries");

  es = require("../../baio-es/es");

  neo.setConfig({
    uri: process.env.NEO4J_URI
  });

  _alignName = function(name) {
    return name.replace(/^\s+|\s+$/g, '').toLowerCase();
  };

  exports.parseNames = function(body, type, done) {
    var docs, names;

    names = [];
    body.results.bindings.forEach(function(m) {
      if (type === "person") {
        names.push({
          key: m.s.value,
          val: _alignName(m.given_name.value + " " + m.sur_name.value),
          lang: m.given_name["xml:lang"]
        });
      }
      names.push({
        key: m.s.value,
        val: _alignName(m.name.value),
        lang: m.name["xml:lang"]
      });
      names.push({
        key: m.s.value,
        val: _alignName(m.label.value),
        lang: m.label["xml:lang"]
      });
      return names.push({
        key: m.s.value,
        val: _alignName(m.foaf_name.value),
        lang: m.foaf_name["xml:lang"]
      });
    });
    names = _.uniq(names, false, function(i) {
      return i.val + i.lang;
    });
    docs = names.map(function(m) {
      return {
        _id: m.val,
        _type: type,
        val: m.val,
        lang: m.lang,
        key: m.key
      };
    });
    return es.bulk(process.env.ES_URI, "" + type + "-names", docs, done);
  };

  exports.parseNode = function(pediaJson) {
    return {
      value: decodeURIComponent(pediaJson[0].n.data.uri),
      type: pediaJson[0].n.data.type
    };
  };

}).call(this);

/*
//@ sourceMappingURL=parser.map
*/
