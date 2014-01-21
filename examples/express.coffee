_              = require "underscore"
{Nodecaster}   = require "../src/nodecaster"
express        = require "express"
fs             = require "fs"

app = express()

nodecaster = Nodecaster.Express.enableServer app

# A pre-defined mount point with basic auth

app.post "/bla", nodecaster.addSource(
  auth: express.basicAuth("username", "password")
)

# An on-demand mount point

baseDir = "/tmp/mp3"
files = fs.readdirSync baseDir

getFile = ->
  baseDir + "/" + _.find _.shuffle(files), (file) ->
    /\.mp3$/i.test file

app.get "/on-demand", (req, res, next) ->
  icyMetadata = req.get("Icy-MetaData") == "1"

  input  = fs.createReadStream getFile()
  source = new Nodecaster.Source.Mpeg
  client = new Nodecaster.Client.Mpeg
    icyMetadata: icyMetadata
    metadata:
      title: "On-demand stream for your pleasure!"

  res.set "Content-Type", "audio/mpeg"
  res.set "icy-metaint", client.icyMetadataInterval if icyMetadata

  input.pipe(source).pipe(client).pipe res

# A generic mount point with no auth

app.post "/:mount", nodecaster.addSource()

app.listen 8000
