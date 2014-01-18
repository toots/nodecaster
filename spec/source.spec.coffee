{Client} = require "../src/client"
{Source} = require "../src/source"

describe "Source", ->
  it "should always be in flowing mode", ->
    ret = null
    spyOn(Source.__super__, "on").andCallFake (event) ->
      ret = event

    source = new Source

    expect(ret).toEqual "data"

  it "should know how to add clients", ->
    source = new Source
    client = new Client

    spyOn source, "pipe"

    source.addClient client

    expect(source.pipe).toHaveBeenCalledWith client
    expect(source.clients[0]).toEqual client

  it "should know how to remove clients", ->
    source = new Source
    client = new Client

    source.addClient client
    
    spyOn source, "unpipe"
    
    source.removeClient client

    expect(source.unpipe).toHaveBeenCalledWith client
    expect(source.clients).toEqual []
