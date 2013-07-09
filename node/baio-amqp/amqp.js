// Generated by CoffeeScript 1.6.2
(function() {
  var amqp, async, connectQueue, _con, _config, _exch, _queues;

  async = require("async");

  amqp = require("amqp");

  _config = null;

  _con = null;

  _exch = null;

  _queues = {};

  exports.setConfig = function(config) {
    return _config = config;
  };

  exports.connect = function(done) {
    if (!_con) {
      _con = amqp.createConnection(_config);
      _con.on("ready", function() {
        return _con.exchange("", {
          durable: true,
          autoDelete: false
        }, function(exch) {
          _exch = exch;
          return done(null);
        });
      });
      return _con.on("error", function(exception) {
        return console.log(exception);
      });
    }
  };

  exports.pub = function(queue, data) {
    return _exch.publish(queue, data, {
      deliveryMode: 2,
      contentType: "application/json"
    });
  };

  exports.sub = function(opts, done) {
    return connectQueue(opts.queue, function(err, q) {
      if (!err) {
        q.subscribe({
          ack: true,
          prefetchCount: 1
        }, function(message) {
          return opts.onPop(message, function() {
            return q.shift();
          });
        });
      }
      return done(err);
    });
  };

  connectQueue = function(queue, done) {
    return _con.queue(queue, {
      durable: true,
      autoDelete: false
    }, function(q) {
      q.bind("#");
      return done(null, q);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=amqp.map
*/
