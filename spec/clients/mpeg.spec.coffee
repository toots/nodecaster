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

