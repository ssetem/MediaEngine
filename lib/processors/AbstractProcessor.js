(function() {
  var AbstractProcessor;
  AbstractProcessor = (function() {
    function AbstractProcessor() {}
    AbstractProcessor.prototype.process = function(job, errorHandler, nextHandler) {
      return errorHandler({
        errorMessage: "unimplemented processor"
      });
    };
    return AbstractProcessor;
  })();
  module.exports = AbstractProcessor;
}).call(this);
