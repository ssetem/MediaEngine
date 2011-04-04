(function() {
  var Job, JobFlowManager, Step, Util, _;
  Job = require('./domain/Job');
  _ = require('underscore')._;
  Step = require('step');
  Util = require('util');
  JobFlowManager = (function() {
    function JobFlowManager() {}
    JobFlowManager.prototype.processNext = function(func) {
      var self;
      self = this;
      return Step(function() {
        return self.popJob(this);
      }, function(err, job) {
        if (err) {
          func(err);
        }
        if (job != null) {
          if (job.type === "parallel" || job.type === "sequential") {
            return Step(function() {
              job.status = "waiting_on_dependants";
              return job.save(this);
            }, function(err) {
              var sel;
              if (err) {
                func(err);
              }
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
                multi: true
              }, this);
            }, function(err) {
              if (err) {
                Util.log(err);
                func(err);
              }
              Util.log("job:" + job._id + " started " + job.type + " child jobs");
              return func();
            });
          } else if (job.type === "job") {
            return func(null, job);
          } else {
            return func(null, null);
          }
        } else {
          return func(null, null);
        }
      });
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
          return func();
        }
      });
    };
    JobFlowManager.prototype.jobErrored = function(errorOptions, job, next) {
      var cancelRetry;
      cancelRetry = (errorOptions != null ? errorOptions.retry : void 0) === false;
      if (!cancelRetry && job.retryCount < 3) {
        job.status = "retrying";
        job.retryCount++;
        Util.log("job: " + job._id + " errored, attempting retry:" + job.retryCount);
        return job.save(next);
      } else {
        job.status = "failed";
        Util.log("job " + job._id + " failed");
        job.errorMessage = job.errorMessage || "";
        return job.save(next);
      }
    };
    JobFlowManager.prototype.jobSuccessful = function(job, next) {
      var self;
      self = this;
      if (job.nextJobId != null) {
        Step(function() {
          job.status = "completed";
          return job.save(this);
        }, function(err) {
          if (err) {
            Util.log(err);
            next(err);
          }
          return Job.findById(job.nextJobId, function(err, nextJob) {
            if (err) {
              Util.log(err);
              next(err);
            }
            nextJob.status = "ready_for_processing";
            return nextJob.save(next());
          });
        });
      }
      if (job.childJobId != null) {
        return Step(function() {
          job.status = "completed_and_waiting_on_dependants";
          return job.save(this);
        }, function(err) {
          if (err) {
            Util.log(err);
            next(err);
          }
          return Job.findById(job.childJobId, function(err, childJob) {
            if (err) {
              Util.log(err);
              next(err);
            }
            if (childJob != null) {
              childJob.status = "ready_for_processing";
              return childJob.save(this);
            } else {
              Util.log("somethign went wrong");
              return next();
            }
          });
        }, function(err) {
          Util.log("job: " + job._id + " completed, waiting on child jobs");
          return next(err);
        });
      } else {
        job.status = "completed";
        return Step(function() {
          return job.save(this);
        }, function(err) {
          if (err) {
            Util.log(err);
          }
          if (job.parentJobId != null) {
            next();
            return self.notifyParents(job);
          } else {
            Util.log("job: " + job._id + " completed");
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
        if (err) {
          Util.log(err);
        }
        setStatus = function() {
          parentJob.status = "completed";
          return parentJob.save(function(err) {
            if (parentJob.parentJobId != null) {
              return self.notifyParents(parentJob);
            } else {
              ;
            }
          });
        };
        if (parentJob.type === "job" && (parentJob.childJobId != null) && job._id.toString() === parentJob.childJobId.toString()) {
          return setStatus();
        } else if (parentJob.type === "parallel" || parentJob.type === "sequential") {
          return Job.count({
            parentJobId: parentJob._id
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
