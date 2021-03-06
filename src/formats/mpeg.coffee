_             = require "underscore"
{Client}      = require "../client"
{Source}      = require "../source"

class Client.Mpeg extends Client
  constructor: (opts = {}) ->
    super

    @_writableState.objectMode = true

    @metadata            = opts.metadata
    @icyMetadata         = opts.icyMetadata         || false
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
    data = chunk.data

    switch chunk.type
      when "metadata"
        @metadata = data
      when "data"
        unless @icyMetadata
          @push data
          return callback()

        while @byteCount + data.length > @icyMetadataInterval
          before    = data.slice 0, @icyMetadataInterval - @byteCount
          remaining = data.slice @icyMetadataInterval - @byteCount

          afterLen   = Math.min @icyMetadataInterval, remaining.length
          after      = remaining.slice 0, afterLen
          data       = remaining.slice afterLen
          @byteCount = after.length

          @push Buffer.concat [
            before, @buildMetadataBlock(), after
          ]

          @metadata  = null

        if data.length > 0
          @push data
          @byteCount += data.length

    callback()

class Source.Mpeg extends Source
  constructor: ->
    super

    @_readableState.objectMode = true

  onMetadata: (metadata) ->
    @metadata = metadata
    @push
      type: "metadata"
      data: metadata

  _transform: (chunk, encoding, callback) ->
    @push
      type: "data"
      data: new Buffer chunk, encoding

    callback()
