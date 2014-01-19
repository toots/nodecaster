async    = require "async"
ogg      = require "ogg"
{Source} = require "../../src/source"
{Client} = require "../../src/client"

describe "Ogg", ->
  beforeEach ->
    @callback = ->

  afterEach ->
    @callback = null

  describe "Client", ->
    it "should receive a source", ->
      client = new Client.Ogg source: "foo"

      expect(client.source).toEqual "foo"

    it "should prepare itself", ->
      spyOn Client.Ogg.prototype, "prepare"

      client = new Client.Ogg source: {}

      expect(Client.Ogg::prepare).toHaveBeenCalled()

    it "should be able to output header", ->
      streams = [
        { serialno: "aa", firstPage: ["foo", "bar"], secondPage: ["fii", "bor"]}
        { serialno: "bb", firstPage: ["gni", "gno"], secondPage: ["gnu", "gna"]}
      ]

      ret     = []
      streams = {}
      page    = "firstPage"

      client = new Client.Ogg source:
        streams: streams

      spyOn(client, "getStream").andCallFake (serialno) ->
        streams[serialno] ||= {serialno: serialno, firstPage: [], secondPage: []}
        flush: (cb) ->
          ret.push streams[serialno]
          str = {serialno: serialno, firstPage: [], secondPage: []}
          page = "secondPage"
          cb()
        packetin: (packet, cb) ->
          str[page].push packet
          cb()

      client.headerOut ->

      expect(ret).toEqual streams

    it "should flush when reaching page 2 and 3", ->
      client = new Client.Ogg

      stream =
        flush: ->

      spyOn stream, "flush"
      spyOn(client, "getStream").andReturn stream

      fn = ->

      client.onPage "foo", 1, fn

      expect(stream.flush).not.toHaveBeenCalled()

      client.onPage "foo", 2, fn

      expect(stream.flush).toHaveBeenCalledWith fn

      stream.flush.reset()

      client.onPage "foo", 3, fn

      expect(stream.flush).toHaveBeenCalledWith fn

      fn = jasmine.createSpy "callback"
      stream.flush.reset()

      client.onPage "foo", 4, fn

      expect(stream.flush).not.toHaveBeenCalled()
      expect(fn).toHaveBeenCalled()

    it "should be able to add packets", ->
      client = new Client.Ogg

      stream =
        packetin: ->
        pageout:  ->
      ret = null

      spyOn(client, "getStream").andReturn stream

      spyOn(stream, "packetin").andCallFake (packet, cb) ->
        ret = packet
        cb()
      spyOn(stream, "pageout").andCallFake (cb) ->
        cb()

      fn = jasmine.createSpy "callback"

      client.pageIndex = 1
      client.addPacket 1234, "foo", fn

      expect(ret).toEqual "foo"
      expect(fn).toHaveBeenCalled()
      expect(stream.pageout).not.toHaveBeenCalled()

      fn.reset()

      client.pageIndex = 2
      client.addPacket 1234, "bar", fn

      expect(ret).toEqual "bar"
      expect(fn).toHaveBeenCalled()
      expect(stream.pageout).not.toHaveBeenCalled()

      fn.reset()
 
      client.pageIndex = 3
      client.addPacket 1234, "gni", fn

      expect(ret).toEqual "gni"
      expect(fn).toHaveBeenCalled()
      expect(stream.pageout).not.toHaveBeenCalled()

      fn.reset()

      client.pageIndex = 4
      client.addPacket 1234, "gno", fn

      expect(ret).toEqual "gno"
      expect(fn).toHaveBeenCalled()
      expect(stream.pageout).toHaveBeenCalled()

    it "should know how to transform data", ->
      client = new Client.Ogg

      spyOn client, "onPage"
      spyOn client, "addPacket"

      fn = ->

      client._transform {serialno: 432, type: "page", index: 123}, null, fn

      expect(client.onPage).toHaveBeenCalledWith 432, 123, fn

      client._transform {serialno: 432, type: "packet", data: "bla"}, null, fn

      expect(client.addPacket).toHaveBeenCalledWith 432, "bla", fn

  describe "Source", ->
    it "should know to handle a stream", ->
      pageCb   = null
      packetCb = null
      eosCb    = null

      stream =
        serialno: 123
        on: (event, cb) ->
          switch event
            when "page" then pageCb = cb
            when "packet" then packetCb = cb
            when "eos" then eosCb = cb

      decoder =
        on: (event, cb) ->
          switch event
            when "stream" then cb stream

      spyOn(decoder, "on").andCallThrough()

      spyOn(ogg, "Decoder").andReturn decoder

      source = new Source.Ogg

      spyOn source, "push"
      
      expect(decoder.on).toHaveBeenCalled()
      expect(source.streams).toEqual [{serialno: 123, firstPage:  [], secondPage: []}]

      pageCb()

      expect(source.push).toHaveBeenCalledWith
        type:     "page"
        index:    1
        serialno: 123

      source.push.reset()

      packetCb "foo"

      expect(source.push).toHaveBeenCalledWith
        type:     "packet"
        serialno: 123
        data:     "foo"
      expect(source.streams).toEqual [{serialno: 123, firstPage:  ["foo"], secondPage: []}]

      source.push.reset()

      pageCb()

      expect(source.push).toHaveBeenCalledWith
        type:     "page"
        index:    2
        serialno: 123

      source.push.reset()

      packetCb "bar"

      expect(source.push).toHaveBeenCalledWith
        type:     "packet"
        serialno: 123
        data:     "bar"
      expect(source.streams).toEqual [{serialno: 123, firstPage:  ["foo"], secondPage: ["bar"]}]

      source.push.reset()

      pageCb()

      expect(source.push).toHaveBeenCalledWith
        type:     "page"
        index:    3
        serialno: 123

      source.push.reset()

      packetCb "gni"

      expect(source.push).toHaveBeenCalledWith
        type:     "packet"
        serialno: 123
        data:     "gni"
      expect(source.streams).toEqual [{serialno: 123, firstPage:  ["foo"], secondPage: ["bar"]}]

      eosCb()

      expect(source.streams).toEqual []

    it "should know how to _transform data", ->
      source = new Source.Ogg

      spyOn source.decoder, "write"

      cb = ->

      source._transform "foo", null, cb

      expect(source.decoder.write).toHaveBeenCalledWith "foo", cb

