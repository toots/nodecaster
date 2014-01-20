{PassThrough} = require "stream"

class module.exports.Client extends PassThrough
  constructor: (opts = {}) ->
    super

    @pipe opts.destination if opts.destination?

    @on "metadata", (metadata) ->
      @metadata = metadata

    @on "data", ->

require "./formats/mpeg"
require "./formats/ogg"
