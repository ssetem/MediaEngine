(function() {
  var AbstractProcessor, MediaItem;
  MediaItem = require('../domain/MediaItem');
  AbstractProcessor = (function() {
    function AbstractProcessor(jobContext) {
      this.jobContext = jobContext;
    }
    return AbstractProcessor;
  })();
  module.exports = AbstractProcessor;
}).call(this);
