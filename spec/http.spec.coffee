{HttpHandler} = require "../src/http"
{Source}      = require "../src/source"

describe "HttpHandler", ->
  beforeEach ->
    @mount = "foo"

    @app =
      get: ->

      routes:
        get: [{ path: @mount }]

    @source = source = new Source

    class @TestHandler extends HttpHandler
      createSource: ->
        source

      createClient: ->

  afterEach: ->
    @app = @mount = @source = @TestHandler = null

  it "should create a source when initialized", ->
    spyOn(@TestHandler.prototype, "createSource").andCallThrough()

    new @TestHandler @app, @mount

    expect(@TestHandler::createSource).toHaveBeenCalled()
