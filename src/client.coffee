{PassThrough} = require "stream"

class module.exports.Client extends PassThrough
  constructor: (opts = {}) ->
    super highWaterMark: opts.queueSize || 524288

    @on "metadata", (metadata) =>
      @metadata = metadata

    @pipe opts.destination if opts.destination?
