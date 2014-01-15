_             = require "underscore"
{Client}      = require "../client"
{HttpHandler} = require "../http"
{Source}      = require "../source"

module.exports.Mpeg = Mpeg = {}

class Mpeg.Client extends Client
  constructor: (opts = {}) ->
    super

    @icyMetadata         = opts.icyMetadata || false
    @icyMetadataInterval = opts.icyMetadataInterval || 16000
    @byteCount           = 0

  buildMetadataBlock: ->
    unless @metadata?
      data = new Buffer 1
      data.fill 0
      return data

    title = @metadata.title || "Unknown title"
    if @metadata.artist?
      title += " -- #{@metadata.artist}"

    title = "StreamTitle='#{title.replace(/'/g, "\\'")}';"

    if title.length > 4080
      title = "#{title.slice(0, 4080 - 5)}...';"

    length = Math.ceil title.length / 16

    data = new Buffer (1+length*16)
    data.fill 0

    data.writeUInt8 length, 0
    data.write      title,  1

    data

  _transform: (chunk, encoding, callback) ->
    return super unless @icyMetadata

    data = new Buffer chunk, encoding

    if @byteCount + data.length > @icyMetadataInterval
      before = data.slice 0, @icyMetadataInterval - @byteCount
      after  = data.slice @icyMetadataInterval - @byteCount

      @push Buffer.concat [
        before, @buildMetadataBlock(), after
      ]

      @metadata  = null
      @byteCount = after.length
    else
      @push data
      @byteCount += data.length

    callback()

Mpeg.Source = Source

class Mpeg.HttpHandler extends HttpHandler
  constructor: ->
    super

    @metadataHandler = (req, res, next) =>
      return next() unless req.query.mount == @mount

      @source.emit "metadata", title: req.query.title, artist: req.query.artist
      res.send "Thanks, brah!"

    @app.use "/admin/metadata", @metadataHandler

  destroy: ->
    super

    # Gni..
    @app.stack = _.reject @app.stack, ({handle}) =>
      handle == @metadataHandler

  createClient: (req, res, next) ->
    if req.get("Icy-MetaData") == "1"
      icyMetadata = true
    else
      icyMetadata = false

    client = new Mpeg.Client
      icyMetadata: icyMetadata
      destination: res

    res.set "icy-metaint", client.icyMetadataInterval if icyMetadata
    res.set "Content-Type", "audio/mpeg"

    next client

  createSource: ->
    @source = new Mpeg.Source
