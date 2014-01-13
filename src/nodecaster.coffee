{MpegClient} = require "./clients/mpeg"
{Stream}     = require "./stream"
express      = require "express"

source = new Stream
hasSource = false

app = express()

app.get "/source", (req, res) ->
  res.status(404).end("no source!") unless hasSource

  if req.get("Icy-MetaData") == "1"
    icyMetadata = true
  else
    icyMetadata = false

  client = new MpegClient icyMetadata: icyMetadata

  res.set "icy-metaint", client.icyMetadataInterval

  source.pipe(client).pipe res

app.post "/source", (req, res) ->
  return res.status(503).end("mount point taken!") if hasSource

  hasSource = true

  req.on "end", ->
    hasSource = false
    req.unpipe source

  req.pipe source

  res.send "Thanks, brah!"

app.get "/admin/metadata", (req, res) ->
  source.emit "metadata", title: req.query.title, artist: req.query.artist
  res.send "Thanks, brah!"

app.listen 8000
