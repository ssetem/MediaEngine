(function() {
  var AbstractProcessor, ZipProcessor, spawn;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractProcessor = require('./AbstractProcessor');
  spawn = require('child_process').spawn;
  ZipProcessor = (function() {
    function ZipProcessor() {
      ZipProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(ZipProcessor, AbstractProcessor);
    ZipProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      var compress, d;
      if ((job != null ? job.data : void 0) != null) {
        d = job.data;
        compress = spawn('tar', ['-cvvf', "" + d.output + "/file-" + (new Date().getTime()) + ".tar", d.output]);
        return compress.on('exit', function(code) {
          if (code === 1) {
            errorHandler({
              errorMessage: "could not zip it"
            });
          }
          return nextHandler();
        });
      } else {
        return errorHandler({
          errorMessage: "could not zip it"
        });
      }
    };
    return ZipProcessor;
  })();
  module.exports = ZipProcessor;
}).call(this);
