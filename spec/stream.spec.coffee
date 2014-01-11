{Stream} = require "../src/stream"

describe "Stream", ->
  it "should initialize with the proper queue size", ->
    spyOn Stream.__super__, "constructor"

    new Stream queueSize: 1234

    expect(Stream.__super__.constructor).toHaveBeenCalledWith highWaterMark: 1234

    new Stream

    expect(Stream.__super__.constructor).toHaveBeenCalledWith highWaterMark: 524288

  it "should initialize an array of clients", ->
    client = new Stream queueSize: 1234

    expect(client.clients).not.toBeNull()

  it "should forward metadata events to connected pipes", ->
    client1 = new Stream
    client2 = new Stream

    client1.pipe client2

    spyOn client2, "emit"

    client1.emit "metadata", "foo"

    expect(client2.emit).toHaveBeenCalledWith "metadata", "foo"

  it "should stop forwarding events when pipes are disconnected", ->
    client1 = new Stream
    client2 = new Stream

    client1.pipe client2
    client1.unpipe client2

    spyOn client2, "emit"

    client1.emit "metadata", "foo"

    expect(client2.emit).not.toHaveBeenCalled()

  it "should disconnect all clients when calling unpipe with no arguments", ->
    client1 = new Stream
    client2 = new Stream
    client3 = new Stream

    client1.pipe client2
    client1.pipe client3

    client1.unpipe()

    spyOn client2, "emit"
    spyOn client3, "emit"

    client1.emit "metadata", "foo"

    expect(client2.emit).not.toHaveBeenCalled()
    expect(client3.emit).not.toHaveBeenCalled()
