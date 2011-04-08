(function() {
  var AbstractJobManager, Job, JobContext, JobFlowManager, JobWorker, async, fs, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractJobManager = require('./AbstractJobManager');
  async = require('async');
  _ = require("underscore")._;
  Job = require('./domain/Job');
  JobContext = require("./domain/JobContext");
  fs = require('fs');
  JobFlowManager = require('./JobFlowManager');
  JobWorker = (function() {
    __extends(JobWorker, AbstractJobManager);
    function JobWorker(options) {
      this.options = options;
      this.takeJob = __bind(this.takeJob, this);;
      JobWorker.__super__.constructor.call(this, this.options);
      this.jobFlowManager = new JobFlowManager();
    }
    JobWorker.prototype.takeJob = function(err) {
      var self;
      self = this;
      return this.jobFlowManager.processNext(function(err, job) {
        var missingProcessor, processorClass;
        if (err) {
          console.log(err);
        }
        if (job != null) {
          try {
            processorClass = require("./processors/new/" + job.processor + "Processor");
          } catch (e) {
            console.log(e.stack);
          }
          missingProcessor = function() {
            return self.jobFlowManager.jobErrored({
              retry: false,
              errorMessage: "could not find processor:" + job.processor + "Processor"
            }, job, self.takeJob);
          };
          if (processorClass == null) {
            missingProcessor();
          }
          return JobContext.create(job, function(err, jobContext) {
            var processor, successful;
            if (err) {
              console.log(err);
            }
            processor = new processorClass(jobContext);
            if (processor == null) {
              missingProcessor();
            }
            successful = function() {
              return fs.readdir(jobContext.getCurrentFolder(), function(err, files) {
                var relativeFilePaths;
                files = files || [];
                job.outputFiles = _.map(files, function(f) {
                  return jobContext.getCurrentFolder() + f;
                });
                relativeFilePaths = _.map(files, function(f) {
                  return jobContext.getRelativeCurrentFolder() + f;
                });
                return jobContext.mediaItem.setGenerateOutputFiles(job.jobPath, relativeFilePaths, function(err) {
                  if (err) {
                    console.log(err);
                  }
                  return self.jobFlowManager.jobSuccessful(job, self.takeJob);
                });
              });
            };
            try {
              return processor.process(job, function(errorOptions) {
                return self.jobFlowManager.jobErrored(errorOptions, job, self.takeJob);
              }, function() {
                return setTimeout(successful, 10);
              });
            } catch (e) {
              missingProcessor();
              return console.log(e.stack);
            }
          });
        } else {
          return setTimeout(self.takeJob, 10);
        }
      });
    };
    return JobWorker;
  })();
  module.exports = JobWorker;
}).call(this);
