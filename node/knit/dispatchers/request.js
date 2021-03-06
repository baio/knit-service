// Generated by CoffeeScript 1.6.2
(function() {
  var request;

  request = require("request");

  exports.req = function(req, res, resource, skipAuth, stream) {
    var r;

    if (req.isAuthenticated() || skipAuth) {
      if (req.isAuthenticated()) {
        req.query["user"] = req.user.name;
        req.body["user"] = req.user.name;
      }
      r = request({
        uri: "" + process.env.DISPATCH_URL + "/" + resource,
        qs: req.query,
        json: req.body,
        method: req.method
      });
      if (res) {
        r.pipe(res);
      }
      if (stream) {
        return r.pipe(stream);
      }
    } else {
      if (res) {
        res.writeHead(401);
        return res.end();
      }
    }
  };

}).call(this);

/*
//@ sourceMappingURL=request.map
*/
