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

  it "should register its mount point initialized", ->
    mount = null

    spyOn @TestHandler.prototype, "serveClient"

    spyOn(@app, "get").andCallFake (path, fn) ->
      mount = path
      fn "foo", "bar"

    new @TestHandler @app, @mount

    expect(@app.get).toHaveBeenCalled()
    expect(mount).toEqual @mount
    expect(@TestHandler::serveClient).toHaveBeenCalled()

  it "should destroy itself when source finishes", ->
    event = null

    spyOn @TestHandler.prototype, "destroy"

    spyOn(@source, "on").andCallFake (evt, fn) ->
      event = evt
      fn()

    new @TestHandler @app, @mount

    expect(event).toEqual "finish"
    expect(@TestHandler::destroy).toHaveBeenCalled()

  it "should remove its route on destroy", ->
    handler = new @TestHandler @app, @mount

    handler.destroy()

    expect(@app.routes.get).toEqual {}

  it "should serve client", ->
    handler = new @TestHandler @app, @mount

    event    = null
    request  = null
    response = null

    fakeResponse =
      on: ->

    spyOn @source, "addClient"
    spyOn @source, "removeClient"

    spyOn(fakeResponse, "on").andCallFake (evt, fn) ->
      event = evt
      fn()

    spyOn(handler, "createClient").andCallFake (req, res, fn) ->
      request  = req
      response = res
      fn "gni"

    handler.serveClient "foo", fakeResponse

    expect(handler.createClient).toHaveBeenCalled()
    expect(event).toEqual "end"
    expect(request).toEqual "foo"
    expect(response).toEqual fakeResponse
    expect(@source.addClient).toHaveBeenCalledWith "gni"
    expect(@source.removeClient).toHaveBeenCalledWith "gni"
