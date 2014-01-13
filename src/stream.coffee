_           = require "underscore"
{Transform} = require "stream"

class module.exports.Stream extends Transform
  constructor: (opts = {}) ->
    super highWaterMark: opts.queueSize || 524288

    @clients = []

    @on "metadata", (metadata) ->
      @metadata = metadata

  pipe: (stream) ->
    stream.metadata = @metadata

    callback = (args...) ->
      args.unshift "metadata"
      stream.emit.apply stream, args

    @addListener "metadata", callback

    @clients.push [stream, callback]

    super

  unpipe: (stream) ->
    unless stream?
      _.each @clients, ([str, fn]) =>
        @removeListener "metadata", fn
      @clients = []
      return

    client = _.find @clients, ([str]) ->
      str == stream

    if client?
      @removeListener "metadata", client[1]
      @clients = _.without @clients, client

    super

  _transform: (chunk, encoding, callback) ->
    @push chunk, encoding
    callback()

  _flush: (callback) ->
    callback()
