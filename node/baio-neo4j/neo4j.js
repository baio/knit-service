// Generated by CoffeeScript 1.6.2
(function() {
  var async, req, _config, _createNodes, _createNodesProperties, _createRelations, _getCreateNode, _getCreateRelation, _getGetRelation, _getRelations, _q,
    __hasProp = {}.hasOwnProperty;

  async = require("async");

  req = require("request");

  _config = null;

  exports.setConfig = function(config) {
    return _config = config;
  };

  _q = function(uri, method, data, done) {
    var body;

    if (data) {
      body = JSON.stringify(data);
    }
    console.log(uri, data);
    return req({
      uri: uri,
      method: method,
      body: body,
      headers: {
        'content-type': 'application/json',
        'X-Stream': true
      }
    }, function(err, resp) {
      var j;

      if (!err) {
        j = resp.body ? JSON.parse(resp.body) : null;
      }
      if (Array.isArray(j) && j[0] && (j[0].status < 200 || j[0].status > 299)) {
        err = j;
      }
      return done(err, j);
    });
  };

  exports.query = function(query, params, done) {
    var data;

    data = {
      query: query,
      params: params
    };
    return _q(_config.uri + "/cypher", "post", data, function(err, j) {
      var c, i, obj, r, res, _i, _j, _len, _len1, _ref, _ref1;

      if (!err) {
        res = [];
        _ref = j.data;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          obj = {};
          res.push(obj);
          _ref1 = j.columns;
          for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
            c = _ref1[i];
            obj[c] = r[i];
          }
        }
      }
      return done(err, res);
    });
  };

  _getCreateNode = function(index, keyVal, properties, strategy) {
    return {
      path: "/index/node/" + index + "?uniqueness=" + strategy,
      method: "post",
      data: {
        key: Object.keys(keyVal)[0],
        value: keyVal[Object.keys(keyVal)[0]],
        properties: properties
      }
    };
  };

  exports.createNode = function(index, keyVal, properties, strategy, done) {
    var q;

    q = _getCreateNode(index, keyVal, properties, strategy);
    return _q(_config.uri + q.path, q.method, q.data, done);
  };

  _getCreateRelation = function(index, type, keyVal, startId, endId, properties, strategy) {
    var endUrl, startUrl;

    if (typeof startId === "object") {
      startUrl = startId.self;
    } else {
      startUrl = "" + _config.uri + "/node/" + startId;
    }
    if (typeof endId === "object") {
      endUrl = endId.self;
    } else {
      endUrl = "" + _config.uri + "/node/" + endId;
    }
    return {
      path: "/index/relationship/" + index + "?uniqueness=" + strategy,
      method: "post",
      data: {
        key: Object.keys(keyVal)[0],
        value: keyVal[Object.keys(keyVal)[0]],
        properties: properties,
        start: startUrl,
        end: endUrl,
        type: type
      }
    };
  };

  exports.createRelation = function(index, type, keyVal, startId, endId, properties, strategy, done) {
    var q;

    q = _getCreateRelation(index, type, keyVal, startId, endId, properties, strategy);
    return _q(_config.uri + q.path, q.method, q.data, done);
  };

  exports.createLabels = function(id, labels, done) {
    var url;

    if (typeof id === "object") {
      url = id.labels;
    } else {
      url = "" + _config.uri + "/node/" + id + "/labels";
    }
    return _q(url, "post", labels, done);
  };

  exports.createNodesBatch = function(nodeOpts, nodes, done) {
    var data;

    data = nodes.map(function(m) {
      var q;

      q = _getCreateNode(nodeOpts.index, nodeOpts.keyVal(m), nodeOpts.properties(m), nodeOpts.strategy);
      return {
        method: q.method,
        to: q.path,
        body: q.data
      };
    });
    console.log(data);
    return _q(_config.uri + "/batch", "post", data, done);
  };

  exports.createRelationsBatch = function(relOpts, rels, done) {
    var data;

    data = rels.map(function(m) {
      var q;

      q = _getCreateRelation(relOpts.index, relOpts.type(m), relOpts.keyVal(m), relOpts.startId(m), relOpts.endId(m), relOpts.properties(m), relOpts.strategy);
      return {
        method: q.method,
        to: q.path,
        body: q.data
      };
    });
    console.log(data);
    return _q(_config.uri + "/batch", "post", data, done);
  };

  _getGetRelation = function(startId, type) {
    var startUrl;

    if (typeof startId === "object") {
      startUrl = startId.self;
    } else {
      startUrl = "/node/" + startId;
    }
    return {
      path: "" + startUrl + "/relationships/all/" + type,
      method: "get"
    };
  };

  exports.getRelation = function(startId, type, done) {
    var q;

    q = _getGetRelation(startId, type);
    console.log(q);
    return _q(_config.uri + q.path, q.method, null, done);
  };

  _createNodes = function(nodeOpts, nodes, done) {
    var b, batch, key, node, _i, _len;

    batch = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      b = {
        method: "post"
      };
      batch.push(b);
      if (nodeOpts.index) {
        b.to = "/index/node/" + nodeOpts.index + "?uniqueness=get_or_create";
        key = Object.keys(nodeOpts.keyValue(node))[0];
        b.body = {
          key: key,
          value: encodeURIComponent(nodeOpts.keyValue(node)[key])
        };
      } else {
        b.to = "/node";
      }
    }
    return _q(_config.uri + "/batch", "post", batch, done);
  };

  _createNodesProperties = function(nodeOpts, nodes, neoNodes, done) {
    var batch, body, i, neoNode, node, prop, props, _i, _len;

    batch = [];
    for (i = _i = 0, _len = neoNodes.length; _i < _len; i = ++_i) {
      neoNode = neoNodes[i];
      node = nodes[i];
      body = neoNode.body;
      props = nodeOpts != null ? nodeOpts.properties(node) : void 0;
      if (props) {
        for (prop in props) {
          if (!__hasProp.call(props, prop)) continue;
          batch.push({
            method: "put",
            to: body.property.replace(_config.uri, "").replace("{key}", prop),
            body: props[prop]
          });
        }
      }
    }
    return _q(_config.uri + "/batch", "post", batch, function(err) {
      if (!err) {
        return done(err, neoNodes);
      } else {
        return done(err);
      }
    });
  };

  _getRelations = function(relOpts, rels, neoNodes, done) {
    var b, batch, from_to, rel, start, _i, _len;

    batch = [];
    for (_i = 0, _len = rels.length; _i < _len; _i++) {
      rel = rels[_i];
      b = {
        method: "get"
      };
      batch.push(b);
      from_to = relOpts.nodesIndexes(rel);
      start = neoNodes[from_to[0]].body;
      b.to = start.outgoing_relationships + "/" + relOpts.type(rel);
    }
    return _q(_config.uri + "/batch", "post", batch, done);
  };

  _createRelations = function(relOpts, rels, neoRelations, neoNodes, done) {
    var b, batch, end, from_to, i, key, rel, start, _i, _len;

    batch = [];
    for (i = _i = 0, _len = rels.length; _i < _len; i = ++_i) {
      rel = rels[i];
      if (neoRelations[i].body.length !== 0) {
        continue;
      }
      b = {
        method: "post"
      };
      batch.push(b);
      from_to = relOpts.nodesIndexes(rel);
      start = neoNodes[from_to[0]].body;
      end = neoNodes[from_to[1]].body;
      if (relOpts.index) {
        b.to = "/index/relationship/" + relOpts.index + "?uniqueness=get_or_create";
        key = Object.keys(relOpts.keyValue(rel))[0];
        b.body = {
          key: key,
          value: encodeURIComponent(relOpts.keyValue(rel)[key]),
          type: relOpts.type(rel),
          start: start.self,
          end: end.self
        };
      } else {
        b.to = start.create_relationship;
        b.body = {
          to: end.self,
          type: relOpts.type(rel)
        };
      }
    }
    return _q(_config.uri + "/batch", "post", batch, done);
  };

  exports.createBatch = function(batch, done) {
    return async.waterfall([
      function(ck) {
        return _createNodes(batch.nodeOpts, batch.nodes, ck);
      }, function(neoNodes, ck) {
        return _createNodesProperties(batch.nodeOpts, batch.nodes, neoNodes, ck);
      }
    ], function(err, neoNodes) {
      if (!err && batch.relOpts) {
        return async.waterfall([
          function(ck) {
            return _getRelations(batch.relOpts, batch.rels, neoNodes, ck);
          }, function(neoRelations, ck) {
            return _createRelations(batch.relOpts, batch.rels, neoRelations, neoNodes, ck);
          }
        ], done);
      } else {
        return done(err, neoNodes);
      }
    });
  };

}).call(this);

/*
//@ sourceMappingURL=neo4j.map
*/
