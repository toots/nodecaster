serveSource = require "./express"
express     = require "express"

app = express()

# A pre-defined mount point with basic auth

app.post "/bla", express.basicAuth('username', 'password'), serveSource(app, "bla")

# A generic mount point with no auth

app.post "/:mount", serveSource(app)

app.listen 8000
