_ = require "underscore"

class module.exports.HttpHandler
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

    @app.get @mount, (req, res) =>
      @serveClient req, res

    @source.on "finish", =>
      @destroy()

  destroy: ->
    @app.routes.get = _.reject @app.routes.get, ({path}) =>
      path == @mount

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.addClient client

      res.on "end", =>
        @source.removeClient client
