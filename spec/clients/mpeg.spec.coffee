bufferEqual  = require "buffer-equal"
{MpegClient} = require "../../src/clients/mpeg"

describe "MpegClient", ->
  it "should do initialize with ICY metadata if told to", ->
    client = new MpegClient

    expect(client.icyMetadata).toEqual false
    expect(client.icyMetadataInterval).toEqual 16000

    client = new MpegClient icyMetadata: true, icyMetadataInterval: 1234

    expect(client.icyMetadata).toEqual true
    expect(client.icyMetadataInterval).toEqual 1234

  it "should listen to the metadata events", ->
    client = new MpegClient

    client.emit "metadata", "foo"

    expect(client.metadata).toEqual "foo"

  it "should be able to build a metadata block", ->
    client = new MpegClient

    client.metadata = title: "foobar"

    metadataBlock = new Buffer 33
    metadataBlock.fill 0
    metadataBlock.writeUInt8 2, 0
    metadataBlock.write      "StreamTitle='foobar';", 1

    expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()

  it "should return an empty block where there are no metadata", ->
    client = new MpegClient

    metadataBlock = new Buffer 1
    metadataBlock.fill 0

    expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()

  it "should be able to combine title and artist when given", ->
    client = new MpegClient

    client.metadata = title: "foo", artist: "bar"

    metadataBlock = new Buffer 33
    metadataBlock.fill 0
    metadataBlock.writeUInt8 2, 0
    metadataBlock.write      "StreamTitle='foo -- bar';", 1

    expect(bufferEqual(client.buildMetadataBlock(), metadataBlock)).toBeTruthy()

  it "should cut stream title when too long", ->
    client = new MpegClient

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
