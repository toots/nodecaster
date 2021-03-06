_       = require "underscore"
{Http}  = require "./http"

module.exports.Express = Express =
  enableServer: (app, opts) ->
    new Express.Handler app, opts

class Express.Handler
  constructor: (@app, @opts = {}) ->
    @sources = {}

    @auth = @opts.auth || (res, req, next) ->
      next()

    # Icy metadata update
    unless @opts.noIcyMetadata
      @app.get "/admin/metadata", @metadataHandler
      @app.get "/admin.cgi",      @metadataHandler

  addSource: (mount) => (req, res, next) =>
    mount = req.params.mount unless _.isString mount

    @auth req, res, =>
      mount = "/#{mount}" unless mount[0] == '/'

      if @sources[mount]?
        return res.status(503).end "mount point taken!"

      mime = req.get "Content-Type"

      switch mime
        when "audio/mpeg"
          handler = new Http.Handler.Mpeg @app, mount
        when "application/ogg", "audio/ogg", "video/ogg"
          handler = new Http.Handler.Ogg @app, mount
        else
          return res.send 501

      @sources[mount] = handler

      req.pipe handler.source

      @app.get mount, (req, res) ->
        res.set "Content-Type", mime
        handler.serveClient req, res

      handler.source.on "finish", =>
        delete @sources[mount]

        @app.routes.get = _.reject @app.routes.get, ({path}) =>
          path == mount

      res.send "Thanks, brah!"

  metadataHandler: (req, res, next) =>
    return next() unless req.query?.mount?

    source = @sources[req.query.mount]

    return next() unless source?

    @auth req, res, ->
      source.emit "metadata", title: req.query.title, artist: req.query.artist
      res.send "Thanks, brah!"
