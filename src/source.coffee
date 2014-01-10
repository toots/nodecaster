class module.exports.Source extends Stream.Duplex
  constructor: (opts = {}) ->
    super

    @queueSize = opts.queueSize || 524288
    @queue     = new Buffer @queueSize

  _write: (chunk, encoding, callback) ->
    data = new Buffer chunk, encoding

    if data.length > @queueSize
      @queue = data.slice (data.length - @queueSize)
      return callback()

    @queue = Buffer.concat @queue.slice(data.length), data
    callback()

  _read: (size) ->
    size = Math.min @queueSize, size

    return unless size > 0

    @push @queue.slice 0, size

    @queue = @queue.slice size
