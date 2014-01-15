_      = require "underscore"
{Mpeg} = require "./formats/mpeg"

module.exports = (app, mount) -> (req, res) ->
  mount = req.params.mount unless _.isString mount
   
  mount = "/#{mount}" unless mount[0] == '/'

  if app.routes.get?[mount]?
    return res.status(503).end "mount point taken!"

  switch req.get("Content-Type")
    when "audio/mpeg"
      handler = new Mpeg.HttpHandler app, mount
    else
      return res.send 501

  req.pipe handler.source

  res.send "Thanks, brah!"
