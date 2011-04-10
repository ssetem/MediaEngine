(function() {
  var AbstractProcessor, VideoProcessor;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractProcessor = require('./AbstractProcessor');
  VideoProcessor = (function() {
    function VideoProcessor() {
      VideoProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(VideoProcessor, AbstractProcessor);
    VideoProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      var d;
      if ((job != null ? job.data : void 0) != null) {
        d = job.data;
        return ffmpeg.mp4(d.input, d.output + d.file, function(err, out, code) {
          console.log(arguments);
          if (code === 2) {
            errorHandler({
              errorMessage: "ouch"
            });
          }
          return nextHandler();
        });
      } else {
        return errorHandler({
          errorMessage: "could not video it"
        });
      }
    };
    return VideoProcessor;
  })();
  module.exports = VideoProcessor;
}).call(this);
