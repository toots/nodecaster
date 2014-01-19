_              = require "underscore"
async          = require "async"
ogg            = require "ogg"
{Client}       = require "../client"
{Source}       = require "../source"

class Client.Ogg extends Client
  constructor: (opts = {}) ->
    super

    @_writableState.objectMode = true

    @source = opts.source

    @prepare()

  headerOut: (done) ->
    # First create streams and output all first page
    async.each @source.streams, (({serialno, firstPage}, cb) =>
      @assemblePage firstPage, serialno, cb), =>

      # Then all second page..
      async.each @source.streams, (({serialno, secondPage}, cb) =>
        @assemblePage secondPage, serialno, cb), done

  prepare: ->
    @encoder   = new ogg.Encoder
    @pageIndex = null

    @encoder.on "data", (chunk, encoding) =>
      @push chunk, encoding

    @encoder.on "end", =>
      @prepare()

  getStream: (serialno) ->
    @encoder.streams[serialno] || @encoder.stream(serialno)

  assemblePage: (packets, serialno, done) =>
    stream = @getStream serialno

    async.each packets, ((packet, cb) =>
      stream.packetin packet, cb), ->
        stream.flush done

  onPage: (serialno, @pageIndex, callback) ->
    stream = @getStream serialno

    return callback() unless 2 <= @pageIndex <= 3

    stream.flush callback

  addPacket: (serialno, packet, callback) ->
    stream = @getStream serialno
    stream.packetin packet, =>
      return callback() if @pageIndex <= 3

      stream.pageout callback

  _transform: (chunk, encoding, callback) ->
    serialno = chunk.serialno

    switch chunk.type
      when "page"
        @onPage serialno, chunk.index, callback
      when "packet"
        @addPacket serialno, chunk.data, callback

class Source.Ogg extends Source
  constructor: ->
    super

    @_readableState.objectMode = true

    @decoder = new ogg.Decoder()
    @streams = []

    @decoder.on "stream", (stream) =>
      handler =
        serialno:   stream.serialno
        firstPage:  []
        secondPage: []

      @streams.push handler

      pageIndex = 0

      stream.on "page", =>
        pageIndex++
  
        @push
          type:     "page"
          serialno: stream.serialno
          index:    pageIndex

      stream.on "packet", (packet) =>
        switch pageIndex
          when 1
            handler.firstPage.push packet
          when 2
            handler.secondPage.push packet

        @push
          type:     "packet"
          serialno: stream.serialno
          data:     packet

      stream.on "eos", =>
        @streams = _.without @streams, handler

  _transform: (chunk, encoding, callback) ->
    @decoder.write chunk, callback
