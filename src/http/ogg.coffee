{Ogg}  = require "../formats/ogg"
{Http} = require "../http"

{Client, Source} = Ogg

class Http.Handler.Ogg extends Http.Handler
  createClient: (req, res, done) ->
    client = new Client
      source:      @source
      destination: res

    client.headerOut ->
      done client

  createSource: ->
    @source = new Source
