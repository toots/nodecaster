{Express} = require "./express"
{Http}    = require "./http"
{Mpeg}    = require "./formats/mpeg"
{Ogg}     = require "./formats/ogg"

module.exports.Nodecaster =
  Mpeg:    Mpeg
  Ogg:     Ogg
  Http:    Http
  Express: Express
