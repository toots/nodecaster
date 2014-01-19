{Nodecaster}   = require "../src/nodecaster"
express        = require "express"

app = express()

nodecaster = Nodecaster.Express.enableServer app

# A pre-defined mount point with basic auth

app.post "/bla", nodecaster.addSource(
  auth: express.basicAuth("username", "password")
)

# A generic mount point with no auth

app.post "/:mount", nodecaster.addSource()

app.listen 8000
