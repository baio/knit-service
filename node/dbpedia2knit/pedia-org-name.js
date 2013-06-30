// Generated by CoffeeScript 1.6.2
(function() {
  var name_query, parse, _get_unique, _lang_filter, _lower_filter, _q;

  _q = require("./pedia-query");

  name_query = "\nselect distinct ?s, ?name, ?label, ?foaf_name\nwhere\n{\n?s ?p ?o.\noptional { ?s dbpprop:name ?name }\noptional { ?s rdfs:label ?label }\noptional { ?s foaf:name ?foaf_name }\noptional { ?s dbpprop:nativeName ?native_name }\nFILTER (?s = <{0}>)\n}";

  _lower_filter = function(item) {
    return item.name = item.name.toLowerCase();
  };

  _lang_filter = function(item) {
    if (item.name.match(/^[\u0400-\u0450\s]+$/)) {
      return item.lang = "ru";
    }
  };

  _get_unique = function(items) {
    var item, res, _i, _len;

    res = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      if (!res.filter(function(f) {
        return f.name === item.name && f.lang === item.lang;
      })[0]) {
        res.push(item);
      }
    }
    return res;
  };

  parse = function(bindings) {
    var b, res, _i, _len;

    res = [];
    for (_i = 0, _len = bindings.length; _i < _len; _i++) {
      b = bindings[_i];
      if (b.name) {
        res.push({
          id: b.s.value,
          name: b.name.value,
          lang: b.name["xml:lang"]
        });
      }
      if (b.label) {
        res.push({
          id: b.s.value,
          name: b.label.value,
          lang: b.label["xml:lang"]
        });
      }
      if (b.foaf_name) {
        res.push({
          id: b.s.value,
          name: b.foaf_name.value,
          lang: b.foaf_name["xml:lang"]
        });
      }
    }
    res.map(function(m) {
      _lower_filter(m);
      return _lang_filter(m);
    });
    return _get_unique(res);
  };

  module.exports = function(uri, s, done) {
    var q;

    q = name_query.replace("{0}", s);
    return _q(uri, q, function(err, b) {
      var d;

      if (!err) {
        d = parse(b);
      }
      return done(err, d);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=pedia-org-name.map
*/
