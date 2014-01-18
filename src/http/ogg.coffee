{Ogg}         = require "../formats/ogg"
{HttpHandler} = require "../http"

module.exports.Ogg = Ogg

class Ogg.HttpHandler extends HttpHandler
  createClient: (req, res, done) ->
    client = new Ogg.Client
      source:      @source
      destination: res

    client.headerOut ->
      done client

  createSource: ->
    @source = new Ogg.Source
