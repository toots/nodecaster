// Generated by CoffeeScript 1.6.3
(function() {
  var HttpHandler, Mpeg, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mpeg = require("../formats/mpeg").Mpeg;

  HttpHandler = require("../http").HttpHandler;

  module.exports.Mpeg = Mpeg;

  Mpeg.HttpHandler = (function(_super) {
    __extends(HttpHandler, _super);

    function HttpHandler() {
      _ref = HttpHandler.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    HttpHandler.prototype.createClient = function(req, res, next) {
      var client, icyMetadata;
      if (req.get("Icy-MetaData") === "1") {
        icyMetadata = true;
      } else {
        icyMetadata = false;
      }
      client = new Mpeg.Client({
        icyMetadata: icyMetadata,
        destination: res
      });
      if (icyMetadata) {
        res.set("icy-metaint", client.icyMetadataInterval);
      }
      res.set("Content-Type", "audio/mpeg");
      return next(client);
    };

    HttpHandler.prototype.createSource = function() {
      return this.source = new Mpeg.Source;
    };

    return HttpHandler;

  })(HttpHandler);

}).call(this);