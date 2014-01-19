{Mpeg} = require "../formats/mpeg"
{Http} = require "../http"

{Client, Source} = Mpeg

class Http.Handler.Mpeg extends Http.Handler
  constructor: ->
    super

    @on "metadata", (metadata) ->
      @source?.onMetadata metadata

  createClient: (req, res, done) ->
    if req.get("Icy-MetaData") == "1"
      icyMetadata = true
    else
      icyMetadata = false

    client = new Client
      icyMetadata: icyMetadata
      metadata:    @source?.metadata
      destination: res

    res.set "icy-metaint", client.icyMetadataInterval if icyMetadata
    res.set "Content-Type", "audio/mpeg"

    done client

  createSource: ->
    @source = new Source
