(function() {
  var AbstractJobManager, mongoose, utils;
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  utils = require('util');
  require('./domain/Job');
  AbstractJobManager = (function() {
    function AbstractJobManager(options) {
      this.options = options;
      this.initMongo();
    }
    AbstractJobManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('current_job');
    };
    return AbstractJobManager;
  })();
  module.exports = AbstractJobManager;
}).call(this);
