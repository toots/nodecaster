{enableServer} = require "./express"
express        = require "express"

app = express()

nodeCaster = enableServer app

# A pre-defined mount point with basic auth

app.post "/bla", express.basicAuth('username', 'password'), nodeCaster.addSource("bla", "username", "password")

# A generic mount point with no auth

app.post "/:mount", nodeCaster.addSource("blabla")

app.listen 8000
