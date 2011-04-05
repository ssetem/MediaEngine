(function() {
  var AbstractProcessor, FileUtils, fs;
  FileUtils = require('../FileUtils');
  fs = require('fs');
  AbstractProcessor = (function() {
    function AbstractProcessor(jobContext) {
      this.jobContext = jobContext;
    }
    AbstractProcessor.prototype.createOutputFolder = function() {
      return fs.mkdirSync(this.jobContext.getCurrentFolder(), 0755);
    };
    return AbstractProcessor;
  })();
  module.exports = AbstractProcessor;
}).call(this);
