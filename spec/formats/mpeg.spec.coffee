bufferEqual = require "buffer-equal"
{Client}    = require "../../src/client"
{Source}    = require "../../src/source"

describe "Mpeg", ->
  beforeEach ->
    @callback = ->
  
  afterEach ->
    @callback = null
  
  describe "Client", ->
  
    it "should do initialize with ICY metadata if told to", ->
      client = new Client.Mpeg
  
      expect(client.icyMetadata).toEqual false
      expect(client.icyMetadataInterval).toEqual 16000
  
      client = new Client.Mpeg icyMetadata: true, icyMetadataInterval: 1234
  
      expect(client.icyMetadata).toEqual true
      expect(client.icyMetadataInterval).toEqual 1234
  
    it "should listen to the metadata events", ->
      client = new Client.Mpeg
  
      client.emit "metadata", "foo"
  
      expect(client.metadata).toEqual "foo"
  
    it "should be able to build a metadata block", ->
      client = new Client.Mpeg
  
      client.metadata = title: "foobar"
  
      metadataBlock = new Buffer 33
      metadataBlock.fill 0
      metadataBlock.writeUInt8 2, 0
      metadataBlock.write      "StreamTitle='foobar';", 1
  
      expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()
  
    it "should return an empty block where there are no metadata", ->
      client = new Client.Mpeg
  
      metadataBlock = new Buffer 1
      metadataBlock.fill 0
  
      expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()
  
    it "should be able to combine title and artist when given", ->
      client = new Client.Mpeg
  
      client.metadata = title: "foo", artist: "bar"
  
      metadataBlock = new Buffer 33
      metadataBlock.fill 0
      metadataBlock.writeUInt8 2, 0
      metadataBlock.write      "StreamTitle='foo -- bar';", 1
  
      expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()
  
    it "should cut stream title when too long", ->
      client = new Client.Mpeg
  
      buffer = new Buffer 4083
      buffer.fill "a"
  
      client.metadata = title: buffer.toString()
  
      buffer = new Buffer 4080
      buffer.fill "a"
      buffer.write "StreamTitle='", 0
      buffer.write "...';", 4075
  
      metadataBlock = new Buffer 4081
      metadataBlock.fill 0
      metadataBlock.writeUInt8 255, 0
      metadataBlock.write      buffer.toString(), 1
  
      expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()
  
    it "should do nothing if not using icy metadata", ->
      client = new Client.Mpeg
  
      spyOn Client.Mpeg.__super__, "_transform"
      spyOn client, "buildMetadataBlock"
      spyOn this, "callback"
  
      ret = null
  
      spyOn(client, "push").andCallFake (arg) ->
        ret = arg
  
      client._transform {type: "data", data: "foo"}, null, @callback
  
      expect(client.push).toHaveBeenCalled()
      expect(ret.toString()).toEqual "foo"
      expect(client.buildMetadataBlock).not.toHaveBeenCalled()
      expect(@callback).toHaveBeenCalled()
  
    it "should do nothing when using icy metadata but below byteCount", ->
      client = new Client.Mpeg icyMetadata: true
  
      ret      = null
  
      spyOn(client, "push").andCallFake (data) ->
        ret = data
  
      spyOn client, "buildMetadataBlock"
      spyOn this, "callback"
  
      client._transform {type: "data", data: "foo"}, null, @callback
  
      expect(client.push).toHaveBeenCalled()
      expect(client.buildMetadataBlock).not.toHaveBeenCalled()
      expect(ret.toString()).toEqual "foo"
      expect(@callback).toHaveBeenCalled()
  
    it "should insert metadata when needed", ->
      client = new Client.Mpeg icyMetadata: true, icyMetadataInterval: 4
      client.metadata = title: "foobar"
      client.byteCount = 1
  
      ret = null
  
      metadataBlock = new Buffer 33
      metadataBlock.fill 0
      metadataBlock.writeUInt8 2, 0
      metadataBlock.write      "StreamTitle='foobar';", 1
  
      expected = new Buffer 39
      expected.write "bla", 0
      expected.write "bla", 36
      metadataBlock.copy expected, 3
  
      spyOn(client, "push").andCallFake (data) ->
        ret = data
  
      spyOn this, "callback"
  
      client._transform {type: "data", data: new Buffer("blabla")}, null, @callback
  
      expect(client.push).toHaveBeenCalled()
      expect(bufferEqual(ret,expected)).toBeTruthy()
      expect(client.byteCount).toEqual 3
      expect(client.metadata).toBeNull()
      expect(@callback).toHaveBeenCalled()
  
    it "should process metadata", ->
      client = new Client.Mpeg
  
      spyOn this, "callback"
  
      client._transform {type: "metadata", data: "gni"}, null, @callback
  
      expect(client.metadata).toEqual "gni"
      expect(@callback).toHaveBeenCalled()
  
  describe "Source", ->
    it "should be able to receive metadata", ->
      source = new Source.Mpeg
  
      spyOn source, "push"
  
      source.onMetadata "foo"
  
      expect(source.metadata).toEqual "foo"
      expect(source.push).toHaveBeenCalledWith type: "metadata", data: "foo"

    it "should be able to process data", ->
      source = new Source.Mpeg

      ret = null

      spyOn(source, "push").andCallFake (data) ->
        ret = data

      spyOn this, "callback"

      source._transform "foo", null, @callback

      expect(ret.type).toEqual "data"
      expect(ret.data.toString()).toEqual "foo"
      expect(@callback).toHaveBeenCalled()
