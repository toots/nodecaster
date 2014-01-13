{MpegClient} = require "./clients/mpeg"
{Source}     = require "./source"
express      = require "express"

source = null

app = express()

app.get "/source", (req, res) ->
  return res.status(404).end("no source!") unless source?

  if req.get("Icy-MetaData") == "1"
    icyMetadata = true
  else
    icyMetadata = false

  client = new MpegClient
    icyMetadata: icyMetadata
    destination: res

  res.set "icy-metaint", client.icyMetadataInterval if icyMetadata
  res.set "Content-Type", "audio/mpeg"

  source.addClient client

  res.on "end", ->
    source.removeClient client

app.post "/source", (req, res) ->
  return res.status(503).end("mount point taken!") if source?

  source = new Source

  req.on "end", ->
    source = null

  req.pipe source

  res.send "Thanks, brah!"

app.get "/admin/metadata", (req, res) ->
  source.emit "metadata", title: req.query.title, artist: req.query.artist
  res.send "Thanks, brah!"

app.listen 8000
