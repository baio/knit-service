request = require("./request")

exports.get = (req, res) ->
  request.req(req, res, "pushes")

exports.post = (req, res) ->
  request.req(req, res, "pushes")

exports.put = (req, res) ->
  request.req(req, res, "pushes")

exports.patch = (req, res) ->
  request.req(req, res, "pushes")

exports.delete = (req, res) ->
  request.req(req, res, "pushes")