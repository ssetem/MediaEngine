(function() {
  var UppercaseProcessor, WorkerManager, mongoose, redis, utils, workerManager;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  redis = require('redis');
  utils = require('util');
  UppercaseProcessor = require('./processors/UppercaseProcessor');
  require('./domain/Job');
  WorkerManager = (function() {
    function WorkerManager(options) {
      this.options = options;
      this.takeJob = __bind(this.takeJob, this);;
      this.initMongo();
      this.initRedis();
      this.processor = new UppercaseProcessor();
    }
    WorkerManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('Job');
    };
    WorkerManager.prototype.initRedis = function() {
      return this.redisClient = redis.createClient();
    };
    WorkerManager.prototype.takeJob = function() {
      var self;
      self = this;
      return this.redisClient.rpop('media_engine.jobs', function(err, jobId) {
        if (jobId != null) {
          console.log("got job with id of: " + jobId);
          return Job.findById(jobId, function(err, job) {
            return self.processor.process(job, self.errorHandler, self.takeJob);
          });
        } else {
          return setTimeout(self.takeJob, 10);
        }
      });
    };
    WorkerManager.prototype.errorHandler = function() {
      return console.log("something went wrong :o");
    };
    return WorkerManager;
  })();
  workerManager = new WorkerManager({
    mongoURL: "mongodb://localhost/media_engine",
    redisURL: 'localhost'
  });
  workerManager.takeJob();
}).call(this);
