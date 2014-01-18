{EventEmitter} = require "events"

class module.exports.HttpHandler extends EventEmitter
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.addClient client

      res.on "close", =>
        @source.removeClient client
