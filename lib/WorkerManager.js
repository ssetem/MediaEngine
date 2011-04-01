(function() {
  var UppercaseProcessor, WorkerManager, mongoose, util, workerManager;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  util = require('util');
  UppercaseProcessor = require('./processors/UppercaseProcessor');
  require('./domain/Job');
  WorkerManager = (function() {
    function WorkerManager(options) {
      this.options = options;
      this.errorHandler = __bind(this.errorHandler, this);;
      this.takeJob = __bind(this.takeJob, this);;
      this.initMongo();
      this.processor = new UppercaseProcessor();
    }
    WorkerManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('Job');
    };
    WorkerManager.prototype.takeJob = function() {
      var self;
      self = this;
      return Job.pop(function(err, job) {
        if (job != null) {
          console.log("got unprocessed " + job._id);
          return self.processor.process(job, (function() {
            return job.setStatus('retrying', self.errorHandler);
          }), (function() {
            return job.setStatus('completed', self.takeJob);
          }));
        } else {
          console.log("job queue empty");
          return setTimeout(self.takeJob, 1000);
        }
      });
    };
    WorkerManager.prototype.errorHandler = function() {
      console.log("something went wrong :o");
      return this.takeJob();
    };
    return WorkerManager;
  })();
  workerManager = new WorkerManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  workerManager.takeJob();
}).call(this);
