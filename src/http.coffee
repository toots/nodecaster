{EventEmitter} = require "events"

module.exports.Http = Http = {}

class Http.Handler extends EventEmitter
  # virtual: createClient
  # virtual: createSource

  constructor: (@app, @mount) ->
    @source = @createSource()

  serveClient: (req, res) ->
    @createClient req, res, (client) =>
      @source.pipe client

      res.on "close", =>
        @source.unpipe client

require "./http/mpeg"
require "./http/ogg"
