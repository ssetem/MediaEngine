(function() {
  var Job, JobFlowManager, Step, async, _;
  Job = require('./domain/Job');
  _ = require('underscore')._;
  Step = require('step');
  async = require('async');
  JobFlowManager = (function() {
    function JobFlowManager() {}
    JobFlowManager.prototype.processNext = function(func) {
      var processMultiple, self;
      self = this;
      async.waterfall([
        function(next) {
          return self.popJob(next);
        }, function(job) {
          if (job != null) {
            if (job.isMultiple()) {
              return processMultiple(job);
            } else if (job.type === "job") {
              return func(null, job);
            }
          } else {
            return func(null, null);
          }
        }
      ]);
      return processMultiple = function(job, isNull) {
        if (job === null) {
          return;
        }
        return async.waterfall([
          function(next) {
            return job != null ? job.saveStatus("waiting_on_dependants", next) : void 0;
          }, function(next) {
            var sel;
            sel = {
              parentJobId: job._id
            };
            if (job.type === "sequential") {
              sel.index = 0;
            }
            return Job.collection.update(sel, {
              "$set": {
                status: "ready_for_processing"
              }
            }, {
              upsert: false,
              multi: true,
              safe: false
            }, next);
          }, function() {
            return func(null, null);
          }
        ]);
      };
    };
    JobFlowManager.prototype.popJob = function(func) {
      var filter, self, sort, update;
      self = this;
      filter = {
        "$or": [
          {
            status: "ready_for_processing"
          }, {
            status: "retrying"
          }
        ]
      };
      sort = [["priority", 1]];
      update = {
        "$set": {
          status: "processing",
          lastModified: Date.now
        }
      };
      return Job.collection.findAndModify(filter, sort, update, function(err, job) {
        if (job != null ? job._id : void 0) {
          return Job.findById(job._id, func);
        } else {
          return func(null, null);
        }
      });
    };
    JobFlowManager.prototype.jobErrored = function(errorOptions, job, next) {
      var cancelRetry;
      cancelRetry = (errorOptions != null ? errorOptions.retry : void 0) === false;
      if (!cancelRetry && job.retryCount < 3) {
        job.status = "retrying";
        job.retryCount++;
        return job.save(next);
      } else {
        job.status = "failed";
        job.errorMessage = job.errorMessage || "";
        return job.save(next);
      }
    };
    JobFlowManager.prototype.jobSuccessful = function(job, next) {
      var self;
      self = this;
      if ((job.childJobId != null) && job.status !== "completed") {
        return Step(function() {
          job.status = "completed_and_waiting_on_dependants";
          return job.save(this);
        }, function(err) {
          if (err) {}
          return Job.findById(job.childJobId, function(err, childJob) {
            if (err) {}
            if (childJob != null) {
              childJob.status = "ready_for_processing";
              return childJob.save(this);
            } else {
              return next();
            }
          });
        }, function(err) {
          return next(err);
        });
      } else if (job.nextJobId != null) {
        return Step(function() {
          job.status = "completed";
          return job.save(this);
        }, function(err) {
          if (err) {}
          return Job.findById(job.nextJobId, function(err, nextJob) {
            if (err) {}
            if (nextJob.status !== "completed") {
              nextJob.status = "ready_for_processing";
              return nextJob.save(next);
            }
          });
        });
      } else {
        job.status = "completed";
        return Step(function() {
          return job.save(this);
        }, function(err) {
          if (err) {}
          if (job.parentJobId != null) {
            next();
            return self.notifyParents(job);
          } else {
            return next();
          }
        });
      }
    };
    JobFlowManager.prototype.notifyParents = function(job) {
      var self;
      self = this;
      return Job.findById(job.parentJobId, function(err, parentJob) {
        var setStatus;
        if (err) {}
        setStatus = function() {
          parentJob.status = "completed";
          return self.jobSuccessful(parentJob, (function() {}));
        };
        if (parentJob.type === "job" && (parentJob.childJobId != null) && job._id.toString() === parentJob.childJobId.toString()) {
          return setStatus();
        } else if (parentJob.type === "parallel" || parentJob.type === "sequential") {
          return Job.count({
            parentJobId: parentJob._id,
            status: "completed"
          }, function(err, count) {
            if (parseInt(parentJob.childCount) === parseInt(count)) {
              return setStatus();
            }
          });
        }
      });
    };
    return JobFlowManager;
  })();
  module.exports = JobFlowManager;
}).call(this);
