{Client} = require "../client"
{Http}   = require "../http"
{Source} = require "../source"

class Http.Handler.Ogg extends Http.Handler
  createClient: (req, res, done) ->
    client = new Client.Ogg
      source:      @source
      destination: res

    client.headerOut ->
      done client

  createSource: ->
    @source = new Source.Ogg
