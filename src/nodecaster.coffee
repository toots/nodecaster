serveSource = require "./connect"
express     = require "express"

app = express()

app.post "/:mount", serveSource(app)

app.listen 8000
