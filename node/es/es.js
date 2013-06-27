// Generated by CoffeeScript 1.6.2
(function() {
  var async, bkp, bulk, copy, del, map, req;

  async = require("async");

  req = require("request");

  bulk = function(uri, index, docs, done) {
    var doc, obj, res, _i, _len;

    res = "";
    for (_i = 0, _len = docs.length; _i < _len; _i++) {
      doc = docs[_i];
      obj = {
        "index": {
          "_index": index,
          "_type": doc._type,
          "_id": doc._id
        }
      };
      res += JSON.stringify(obj);
      res += "\r\n";
      obj = JSON.parse(JSON.stringify(doc));
      delete obj._id;
      delete obj._type;
      res += JSON.stringify(obj);
      res += "\r\n";
    }
    return req({
      method: "post",
      uri: "" + uri + "/" + index + "/_bulk",
      body: res
    }, function(err) {
      return done(err);
    });
  };

  map = function(uri, fromIndex, toIndex, docsCount, map, done) {
    if (docsCount == null) {
      docsCount = 10000;
    }
    return req.get({
      uri: "" + uri + "/" + fromIndex + "/_search",
      qs: {
        size: docsCount
      }
    }, function(err, res) {
      var j;

      if (!err) {
        j = JSON.parse(res.body);
        j = j.hits.hits.map(function(m) {
          return map(m);
        });
        return bulk(uri, toIndex, j, done);
      } else {
        return done(err);
      }
    });
  };

  copy = function(uri, fromIndex, toIndex, done) {
    return map(uri, fromIndex, toIndex, null, (function(m) {
      return m;
    }), done);
  };

  del = function(uri, index, done) {
    return req({
      uri: "" + uri + "/" + index,
      method: "delete"
    }, function(err) {
      return done(err);
    });
  };

  bkp = function(uri, from, to, done) {
    return async.waterfall([
      function(ck) {
        return del(uri, to, ck);
      }, function(ck) {
        return copy(uri, from, to, ck);
      }
    ], done);
  };

  exports.copy = copy;

  exports.bulk = bulk;

  exports.map = map;

  exports.bkp = bkp;

  exports.del = del;

}).call(this);

/*
//@ sourceMappingURL=es.map
*/
