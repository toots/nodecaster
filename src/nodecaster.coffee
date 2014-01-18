{enableServer} = require "./express"
express        = require "express"

app = express()

nodeCaster = enableServer app

# A pre-defined mount point with basic auth

app.post "/bla", nodeCaster.addSource(
  auth: express.basicAuth("username", "password")
)

# A generic mount point with no auth

app.post "/:mount", nodeCaster.addSource()

app.listen 8000
