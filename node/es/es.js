// Generated by CoffeeScript 1.6.2
(function() {
  var async, bkp, bulk, copy, createIndex, deleteIndex, fs, getIndex, map, query, req, _r, _r_oper;

  async = require("async");

  fs = require("fs");

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
    return _r_oper(uri, index, "_bulk", "post", res, done);
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

  getIndex = function(opts, done) {
    return _r({
      uri: opts.uri
    }, opts.index, "get", null, done);
  };

  deleteIndex = function(opts, done) {
    return _r(opts.uri, opts.index, "delete", null, done);
  };

  createIndex = function(opts, done) {
    var settings;

    settings = opts.settings;
    if (!settings) {
      settings = JSON.parse(fs.readFileSync(opts.settingsPath, "utf-8"));
    }
    return _r(opts.uri, opts.index, "post", settings, done);
  };

  bkp = function(opts, done) {
    return async.waterfall([
      function(ck) {
        return deleteIndex(opts, ck);
      }, function(ck) {
        return createIndex(opts, ck);
      }, function(ck) {
        return copy(opts, ck);
      }
    ], done);
  };

  query = function(uri, index, q, done) {
    return req.post({
      uri: "" + uri + "/" + index + "/_search",
      body: JSON.stringify(q)
    }, function(err, res) {
      if (!err) {
        return done(null, JSON.parse(res.body).hits.hits.map(function(m) {
          return m._source;
        }));
      } else {
        return done(err);
      }
    });
  };

  _r = function(uri, index, method, body, done) {
    return _r_oper(uri, index, null, method, body, done);
  };

  _r_oper = function(uri, index, oper, method, body, done) {
    var opts;

    opts = {
      uri: "" + uri + "/" + index,
      method: method
    };
    if (oper) {
      opts.uri += "/" + oper;
    }
    if (typeof body === "string") {
      opts.body = body;
    } else if (typeof body === "object") {
      opts.json = body;
    }
    return req(opts, function(err, res) {
      if (res.body.error) {
        err = res.body;
      }
      if (!err) {
        res = res.body && typeof res.body === "string" ? JSON.parse(res.body) : res.body;
        return done(err, res);
      } else {
        return done(err);
      }
    });
  };

  exports.createIndex = createIndex;

  exports.deleteIndex = deleteIndex;

  exports.getIndex = getIndex;

  exports.copy = copy;

  exports.bulk = bulk;

  exports.map = map;

  exports.bkp = bkp;

  exports.query = query;

}).call(this);

/*
//@ sourceMappingURL=es.map
*/
