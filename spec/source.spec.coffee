{Client} = require "../src/client"
{Source} = require "../src/source"

describe "Source", ->
  it "should listen to metadata events", ->
    source = new Source
    source.emit "metadata", "foo"

    expect(source.metadata).toEqual "foo"

  it "should know how to add clients", ->
    source = new Source
    client = new Client

    spyOn client, "emit"
    spyOn source, "pipe"

    source.metadata = "foo"
    source.addClient client

    expect(client.emit).toHaveBeenCalledWith "metadata", "foo"
    expect(source.pipe).toHaveBeenCalledWith client
    expect(source.clients[0]).toEqual client

    source.emit "metadata", "bar"

    expect(client.emit).toHaveBeenCalledWith "metadata", "bar"

  it "should know how to remove clients", ->
    source = new Source
    client = new Client

    source.addClient client
    
    spyOn source, "unpipe"
    
    source.removeClient client

    expect(source.unpipe).toHaveBeenCalledWith client
    expect(source.clients).toEqual []
