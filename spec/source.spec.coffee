{Source} = require "../src/source"

describe "Source", ->
  it "should always be in flowing mode", ->
    ret = null
    spyOn(Source.__super__, "on").andCallFake (event) ->
      ret = event

    source = new Source

    expect(ret).toEqual "data"
