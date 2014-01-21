_             = require "underscore"
{PassThrough} = require "stream"

class module.exports.Source extends PassThrough
  constructor: (opts = {}) ->
    super

    # Always flush data in sources
    @on "data", ->

    @setMaxListeners 0
