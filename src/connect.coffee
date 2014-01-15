_              = require "underscore"
{Mpeg}         = require "./formats/mpeg"

hasRoute = (app, route) ->
  app.routes.get?[route]?

class HttpHandler
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

    @app.get @mount, (req, res) =>
      @serveClient req, res

    @source.on "finish", =>
      @destroy()

  destroy: ->
    @app.routes.get = _.reject @app.routes.get, ({path}) ->
      path == @mount
      

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.addClient client

      res.on "end", =>
        @source.removeClient client

class MpegHandler extends HttpHandler
  constructor: ->
    super

    @metadataHandler = (req, res, next) =>
      return next() unless req.query.mount == @mount

      @source.emit "metadata", title: req.query.title, artist: req.query.artist
      res.send "Thanks, brah!"

    @app.use "/admin/metadata", @metadataHandler

  destroy: ->
    super

    # Gni..
    @app.stack = _.reject @app.stack, ({handle}) =>
      handle == @metadataHandler

  createClient: (req, res, next) ->
    if req.get("Icy-MetaData") == "1"
      icyMetadata = true
    else
      icyMetadata = false

    client = new Mpeg.Client
      icyMetadata: icyMetadata
      destination: res

    res.set "icy-metaint", client.icyMetadataInterval if icyMetadata
    res.set "Content-Type", "audio/mpeg"

    next client

  createSource: ->
    @source = new Mpeg.Source

module.exports = (app) -> (mount, req, res) ->
  unless _.isString mount
    res   = req
    req   = mount
    mount = req.params.mount
   
  mount = "/#{mount}" unless mount[0] == '/'

  if hasRoute app, mount
    return res.status(503).end "mount point taken!"

  switch req.get("Content-Type")
    when "audio/mpeg"
      handler = new MpegHandler app, mount
    else
      return res.send 501

  req.pipe handler.source

  res.send "Thanks, brah!"
