(function() {
  var AbstractProcessor, ImageMetadataProcessor, util;
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
  ImageMetadataProcessor = (function() {
    function ImageMetadataProcessor() {
      ImageMetadataProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(ImageMetadataProcessor, AbstractProcessor);
    ImageMetadataProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      if ((job != null ? job.data : void 0) != null) {
        console.log(job.data);
        return nextHandler();
      } else {
        return errorHandler({
          retry: true
        });
      }
    };
    return ImageMetadataProcessor;
  })();
  module.exports = ImageMetadataProcessor;
}).call(this);
