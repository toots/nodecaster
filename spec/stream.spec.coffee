{Stream} = require "../src/stream"

describe "Stream", ->
  beforeEach ->
    @callback = ->

  afterEach ->
    @callback = ->

  it "should initialize with the proper queue size", ->
    spyOn Stream.__super__, "constructor"

    new Stream queueSize: 1234

    expect(Stream.__super__.constructor).toHaveBeenCalledWith highWaterMark: 1234

    new Stream

    expect(Stream.__super__.constructor).toHaveBeenCalledWith highWaterMark: 524288

  it "should initialize an array of streams", ->
    stream = new Stream queueSize: 1234

    expect(stream.streams).not.toBeNull()

  it "should forward metadata events to connected pipes", ->
    stream1 = new Stream
    stream2 = new Stream

    stream1.pipe stream2

    spyOn stream2, "emit"

    stream1.emit "metadata", "foo"

    expect(stream2.emit).toHaveBeenCalledWith "metadata", "foo"
    expect(stream1.clients[0][0]).toEqual stream2

  it "should stop forwarding events when pipes are disconnected", ->
    stream1 = new Stream
    stream2 = new Stream

    stream1.pipe stream2
    stream1.unpipe stream2

    spyOn stream2, "emit"

    stream1.emit "metadata", "foo"

    expect(stream2.emit).not.toHaveBeenCalled()
    expect(stream1.clients).toEqual []

  it "should disconnect all streams when calling unpipe with no arguments", ->
    stream1 = new Stream
    stream2 = new Stream
    stream3 = new Stream

    stream1.pipe stream2
    stream1.pipe stream3

    expect(stream1.clients[0][0]).toEqual stream2
    expect(stream1.clients[1][0]).toEqual stream3

    stream1.unpipe()

    spyOn stream2, "emit"
    spyOn stream3, "emit"

    stream1.emit "metadata", "foo"

    expect(stream2.emit).not.toHaveBeenCalled()
    expect(stream3.emit).not.toHaveBeenCalled()
    expect(stream1.clients).toEqual []

  it "should pass data untouched", ->
    stream = new Stream

    spyOn stream, "push"
    spyOn this,   "callback"

    stream._transform "foo", "bla", @callback

    expect(stream.push).toHaveBeenCalledWith "foo", "bla"
    expect(@callback).toHaveBeenCalled()
