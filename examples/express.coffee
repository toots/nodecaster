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
  res.set "Content-Type", "audio/mpeg"

  handler = new Nodecaster.Http.Handler.Mpeg

  handler.createClient req, res, (client) ->
    fs.createReadStream(getFile()).pipe handler.source
    handler.serveClient req, res

# A generic mount point with no auth

app.post "/:mount", nodecaster.addSource()

app.listen 8000
