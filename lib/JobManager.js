(function() {
  var JobManager, i, jobManager, mongoose, utils;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  utils = require('util');
  require('./domain/Job');
  JobManager = (function() {
    function JobManager(options) {
      this.options = options;
      this.initMongo();
    }
    JobManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('Job');
    };
    JobManager.prototype.addJob = function() {
      var j;
      j = new Job();
      return j.save(__bind(function(err) {
        return console.log('adding new job:' + j._id);
      }, this));
    };
    return JobManager;
  })();
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  for (i = 1; i <= 50; i++) {
    jobManager.addJob();
  }
}).call(this);
