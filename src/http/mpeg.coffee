{Mpeg}        = require "../formats/mpeg"
{HttpHandler} = require "../http"

module.exports.Mpeg = Mpeg

class Mpeg.HttpHandler extends HttpHandler
  createClient: (req, res, next) ->
    if req.get("Icy-MetaData") == "1"
      icyMetadata = true
    else
      icyMetadata = false

    client = new Mpeg.Client
      icyMetadata: icyMetadata
      destination: res

    res.set "icy-metaint", client.icyMetadataInterval if icyMetadata
    res.set "Content-Type", "audio/mpeg"

    next client

  createSource: ->
    @source = new Mpeg.Source
