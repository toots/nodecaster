_           = require "underscore"
{Transform} = require "stream"

class module.exports.Client extends Transform
  constructor: (opts = {}) ->
    super highWaterMark: opts.queueSize || 524288

    @clients = []

  pipe: (stream) ->
    super

    callback = (args...) ->
      args.unshift "metadata"
      stream.emit.apply stream, args

    @addListener "metadata", callback

    @clients.push [stream, callback]

  unpipe: (stream) ->
    super
    
    unless stream?
      @removeAllListeners "metadata"
      @clients = []
      return

    client = _.find @clients, ([str]) ->
      str == stream

    if client?
      @removeListener "metadata", client[1]
      @clients = _.without @clients, client[0]

  _transform: (chunk, encoding, callback) ->
    @push new Buffer chunk, encoding
    callback()

  _flush: (callback) ->
    callback()
