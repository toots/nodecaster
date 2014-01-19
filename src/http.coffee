{EventEmitter} = require "events"

module.exports.Http = Http = {}

class Http.Handler extends EventEmitter
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.addClient client

      res.on "close", =>
        @source.removeClient client

require "./http/mpeg"
require "./http/ogg"
