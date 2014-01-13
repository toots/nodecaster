{Client} = require "../src/client"

describe "Client", ->
  it "should initialize with the proper queue size", ->
    spyOn(Client.__super__, "constructor").andCallThrough()

    new Client queueSize: 1234

    expect(Client.__super__.constructor).toHaveBeenCalledWith highWaterMark: 1234

    new Client

    expect(Client.__super__.constructor).toHaveBeenCalledWith highWaterMark: 524288

  it "should pipe destination", ->
    spyOn Client.__super__, "pipe"

    new Client destination: "foo"

    expect(Client.__super__.pipe).toHaveBeenCalledWith "foo"

  it "should always be in flowing mode", ->
    ret = null

    spyOn(Client.__super__, "on").andCallFake (event) ->
      ret = event

    new Client

    expect(ret).toEqual "data"

  it "should listen to metadata events", ->
    client = new Client

    client.emit "metadata", "foo"

    expect(client.metadata).toEqual "foo"
