// Generated by CoffeeScript 1.6.2
(function() {
  var createLabels, createNode, createNodesBatch, createRelation, createRelationsBatch, cypherQuery, getRelation, neo, setNodeProperties;

  neo = require("./neo4j");

  neo.setConfig({
    uri: process.env.NEO4J_URI
  });

  cypherQuery = function() {
    return neo.query("start n=node(*) return n, labels(n), id(n);", null, function(err, data) {
      return console.log(err, data);
    });
  };

  createNode = function(uri) {
    return neo.createNode("wiki", {
      uri: uri
    }, {
      uri: uri
    }, "get_or_create", function(err, data) {
      return console.log(err, data);
    });
  };

  createLabels = function(id) {
    return neo.createLabels(id, ["huiki", "check"], function(err, data) {
      return console.log(err, data);
    });
  };

  createRelation = function(uri, n1, n2) {
    return neo.createRelation("wiki", "friend", {
      uri: 3
    }, 15, 16, {
      uri: 3
    }, "get_or_create", function(err, data) {
      return console.log(err, data);
    });
  };

  createNodesBatch = function() {
    return neo.createNodesBatch({
      index: "wiki",
      keyVal: (function(p) {
        return {
          uri: p.uri
        };
      }),
      properties: (function(p) {
        return {
          uri: p.uri
        };
      }),
      strategy: "get_or_create"
    }, [
      {
        uri: 1
      }, {
        uri: 4
      }
    ], function(err, data) {
      return console.log(err, data);
    });
  };

  createRelationsBatch = function() {
    return neo.createRelationsBatch({
      index: "wiki",
      type: "friend",
      keyVal: (function(p) {
        return {
          uri: p.uri
        };
      }),
      startId: (function(p) {
        return p.startId;
      }),
      endId: (function(p) {
        return p.endId;
      }),
      properties: (function(p) {
        return p.data;
      }),
      strategy: "get_or_create"
    }, [
      {
        uri: 101,
        startId: 15,
        endId: 16,
        data: {
          uri: 101
        }
      }
    ], function(err, data) {
      return console.log(err, data);
    });
  };

  setNodeProperties = function(id) {
    return neo.setNodeProperties(id, {
      names: ["test"]
    }, function(err, data) {
      return console.log(err, data);
    });
  };

  getRelation = function(id) {
    return neo.getRelation(id, "friend", function(err, data) {
      return console.log(err, data);
    });
  };

  getRelation(109);

}).call(this);

/*
//@ sourceMappingURL=neo4j.test.map
*/
