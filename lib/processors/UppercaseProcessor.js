(function() {
  var AbstractProcessor, UppercaseProcessor;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractProcessor = require('./AbstractProcessor');
  UppercaseProcessor = (function() {
    function UppercaseProcessor() {
      UppercaseProcessor.__super__.constructor.apply(this, arguments);
    }
    __extends(UppercaseProcessor, AbstractProcessor);
    UppercaseProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      return setTimeout(function() {
        if (new Date().getTime() % 2 || true) {
          console.log(job._id + " " + job.data.processor);
          return nextHandler();
        } else {
          return errorHandler({
            retry: true
          });
        }
      }, Math.round(Math.random() * 0));
    };
    return UppercaseProcessor;
  })();
  module.exports = UppercaseProcessor;
}).call(this);
