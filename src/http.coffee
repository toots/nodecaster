_ = require "underscore"

class module.exports.HttpHandler
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.addClient client

      res.on "end", =>
        @source.removeClient client
