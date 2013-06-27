request = require("./request")

exports.get = (req, res) ->
  request.req(req, res, "tags", true)
