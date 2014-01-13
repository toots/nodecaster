_             = require "underscore"
{PassThrough} = require "stream"

class module.exports.Source extends PassThrough
  constructor: (opts = {}) ->
    super

    @on "metadata", (metadata) ->
      @metadata = metadata

      _.each @clients, (client) =>
        client.emit "metadata", metadata

    # Always flush data in sources
    @on "data", ->

    @clients = []

  addClient: (client) ->
    @clients.push client

    client.emit "metadata", @metadata if @metadata?

    @pipe client

  removeClient: (client) ->
    @clients = _.without @clients, client

    @unpipe client
