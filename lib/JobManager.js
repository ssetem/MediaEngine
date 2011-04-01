(function() {
  var JobManager, i, jobManager, mongoose, redis, utils;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  redis = require('redis');
  utils = require('util');
  require('./domain/Job');
  JobManager = (function() {
    function JobManager(options) {
      this.options = options;
      this.initMongo();
      this.initRedis();
    }
    JobManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('Job');
    };
    JobManager.prototype.initRedis = function() {
      return this.redisClient = redis.createClient();
    };
    JobManager.prototype.addJob = function() {
      var j;
      j = new Job();
      return j.save(__bind(function(err) {
        console.log('adding new job:' + j._id);
        return this.redisClient.lpush('media_engine.jobs', j._id);
      }, this));
    };
    return JobManager;
  })();
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine",
    redisURL: 'localhost'
  });
  for (i = 1; i <= 10; i++) {
    jobManager.addJob();
  }
}).call(this);
