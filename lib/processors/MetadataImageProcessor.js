(function() {
  var AbstractProcessor, FileUtils, ImageMetadataProcessor, im;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractProcessor = require('./AbstractProcessor');
  FileUtils = require('../FileUtils');
  im = require('imagemagick');
  ImageMetadataProcessor = (function() {
    function ImageMetadataProcessor() {
      ImageMetadataProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(ImageMetadataProcessor, AbstractProcessor);
    ImageMetadataProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      var d;
      if ((job != null ? job.data : void 0) != null) {
        d = job.data;
        return im.readMetadata(d.input, function(err, metadata) {
          var getMetadata, type, _i, _len, _ref, _results;
          if (err != null) {
            return errorHandler({
              errorMessage: err.toString()
            });
          } else {
            getMetadata = function(metadata, type) {
              var fileName, json;
              if (metadata[type] != null) {
                json = JSON.stringify(metadata[type]);
                fileName = "" + d.output + d.name + "-" + type + ".json";
                return FileUtils.writeFile(fileName, json, function(err) {
                  if (err) {
                    errorHandler(err);
                  }
                  return nextHandler();
                });
              }
            };
            _ref = ["exif", "iptc"];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              type = _ref[_i];
              _results.push(getMetadata(metadata, type));
            }
            return _results;
          }
        });
      } else {
        return errorHandler({
          errorMessage: "no data provided for image metadata"
        });
      }
    };
    return ImageMetadataProcessor;
  })();
  module.exports = ImageMetadataProcessor;
}).call(this);
