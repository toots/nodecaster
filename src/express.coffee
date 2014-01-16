_       = require "underscore"
express = require "express"
{Mpeg}  = require "./http/mpeg"

class ExpressHandler
  constructor: (@app) ->
    @sources = {}

  addSource: (mount, user, password) => (req, res, next) =>
    unless _.isString user
      user  = mount
      mount = req.params.mount

    if _.isString user and !_.isString password
      password = user
      user     = "source"

    mount = "/#{mount}" unless mount[0] == '/'

    if @sources[mount]?
      return res.status(503).end "mount point taken!"

    switch req.get("Content-Type")
      when "audio/mpeg"
        handler = new Mpeg.HttpHandler @app, mount
      else
        return res.send 501

    @sources[mount] =
      handler:  handler
      user:     user
      password: password

    req.pipe handler.source

    @app.get mount, (req, res) ->
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

    fn = (req, res, next) ->
      return next() unless source.user? and source.password?

      express.basicAuth(source.user, source.password) req, res, next

    fn req, res, ->
      source.handler.source.emit "metadata", title: req.query.title, artist: req.query.artist
      res.send "Thanks, brah!"

module.exports =
  enableServer: (app) ->
    nodeCaster = new ExpressHandler app
 
    # Icy metadata update
    app.get "/admin/metadata", nodeCaster.metadataHandler
    app.get "/admin.cgi",      nodeCaster.metadataHandler

    nodeCaster
