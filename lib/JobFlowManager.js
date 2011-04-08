(function() {
  var Job, JobFlowManager, Step, async, util, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Job = require('./domain/Job');
  _ = require('underscore')._;
  Step = require('step');
  util = require('util');
  async = require('async');
  JobFlowManager = (function() {
    function JobFlowManager() {}
    JobFlowManager.prototype.processNext = function(func) {
      var errorFunction;
      errorFunction = this.createErrorFunction(func);
      return async.waterfall([
        function(next) {
          return Job.popJob(next);
        }, function(job) {
          if (job != null) {
            if (job.isMultiple()) {
              return job.startChildren(function(err) {
                return func(err, null);
              });
            } else if (job.type === "job") {
              return func(null, job);
            }
          } else {
            return func(null, null);
          }
        }
      ], errorFunction);
    };
    JobFlowManager.prototype.jobErrored = function(errorOptions, job, next) {
      var cancelRetry;
      cancelRetry = (errorOptions != null ? errorOptions.retry : void 0) === false;
      if (!cancelRetry && job.retryCount < 3) {
        job.status = "retrying";
        job.retryCount++;
        util.log("job: " + job._id + " " + job.jobPath + " errored, attempting retry:" + job.retryCount);
      } else {
        job.status = "failed";
        util.log("job " + job._id + " " + job.jobPath + " failed");
      }
      job.errorMessage = job.errorMessage || "";
      util.log(errorOptions.errorMessage || "");
      return job.save(next);
    };
    JobFlowManager.prototype.jobSuccessful = function(job, callback) {
      var errorFunction, self;
      self = this;
      errorFunction = this.createErrorFunction(callback);
      if ((job.childJobId != null) && job.status !== "completed") {
        return async.waterfall([
          function(next) {
            return job.saveStatus("completed_and_waiting_on_dependants", next);
          }, function(next) {
            return Job.findById(job.childJobId, function(err, childJob) {
              if (childJob != null) {
                return childJob.saveStatus("ready_for_processing", next);
              } else {
                util.log("somethign went wrong");
                return next(new Error("should have child id"));
              }
            });
          }, function() {
            return callback(null);
          }
        ], errorFunction);
      } else if (job.nextJobId != null) {
        return async.waterfall([
          function(next) {
            return job.saveStatus("completed", next);
          }, function(next) {
            return Job.findById(job.nextJobId, function(err, nextJob) {
              errorFunction(err);
              if (nextJob.status !== "completed") {
                return nextJob.saveStatus("ready_for_processing", next);
              }
            });
          }, function() {
            return callback(null);
          }
        ], errorFunction);
      } else {
        return async.waterfall([
          function(next) {
            return job.saveStatus("completed", next);
          }, function() {
            if (job.type === "job") {
              util.log("job: " + job._id + " completed " + job.jobPath);
            }
            if (job.parentJobId != null) {
              self.notifyParents(job);
            }
            return callback(null);
          }
        ], errorFunction);
      }
    };
    JobFlowManager.prototype.notifyParents = function(job) {
      return Job.findById(job.parentJobId, __bind(function(err, parentJob) {
        var setStatus;
        if (err) {
          util.log(err);
        }
        setStatus = __bind(function() {
          parentJob.status = "completed";
          return this.jobSuccessful(parentJob, (function() {}));
        }, this);
        if (parentJob.type === "job" && (parentJob.childJobId != null) && job._id.toString() === parentJob.childJobId.toString()) {
          return setStatus();
        } else if (parentJob.isMultiple()) {
          return Job.count({
            parentJobId: parentJob._id,
            status: "completed"
          }, function(err, count) {
            if (parseInt(parentJob.childCount) === parseInt(count)) {
              return setStatus();
            }
          });
        }
      }, this));
    };
    JobFlowManager.prototype.createErrorFunction = function(callback) {
      return function(err) {
        if (err != null) {
          util.log(err);
          return callback(err);
        }
      };
    };
    return JobFlowManager;
  })();
  module.exports = JobFlowManager;
}).call(this);
