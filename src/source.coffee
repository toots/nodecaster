_             = require "underscore"
{PassThrough} = require "stream"

class module.exports.Source extends PassThrough
  constructor: (opts = {}) ->
    super

    # Always flush data in sources
    @on "data", ->

    @clients = []

    @setMaxListeners 0

  addClient: (client) ->
    @clients.push client
    @pipe client

  removeClient: (client) ->
    @clients = _.without @clients, client
    @unpipe client
