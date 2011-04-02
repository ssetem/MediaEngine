(function() {
  var AbstractProcessor, ImageMagickProcessor, im, util;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractProcessor = require('./AbstractProcessor');
  util = require('util');
  im = require('imagemagick');
  ImageMagickProcessor = (function() {
    function ImageMagickProcessor() {
      ImageMagickProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(ImageMagickProcessor, AbstractProcessor);
    ImageMagickProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      var d, params;
      if ((job != null ? job.data : void 0) != null) {
        d = job.data;
        params = {
          srcPath: d.input,
          dstPath: d.output,
          width: d.width
        };
        return im.resize(params, function(err, stdout, stderr) {
          if (err) {
            return errorHandler({
              errorMessage: err.toString()
            });
          } else {
            console.log(stdout);
            return nextHandler();
          }
        });
      }
    };
    return ImageMagickProcessor;
  })();
  module.exports = ImageMagickProcessor;
}).call(this);
