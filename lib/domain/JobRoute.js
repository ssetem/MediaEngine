(function() {
  var Job, JobRouteManager, Marker, Par, Seq, SimpleJob, _;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Job = require('./Job');
  _ = require('underscore')._;
  Marker = (function() {
    function Marker() {}
    return Marker;
  })();
  Par = (function() {
    __extends(Par, Marker);
    function Par(subjobs) {
      this.subjobs = subjobs;
    }
    return Par;
  })();
  Seq = (function() {
    __extends(Seq, Marker);
    function Seq(subjobs) {
      this.subjobs = subjobs;
    }
    return Seq;
  })();
  SimpleJob = (function() {
    __extends(SimpleJob, Marker);
    function SimpleJob(options) {
      var k, v;
      for (k in options) {
        if (!__hasProp.call(options, k)) continue;
        v = options[k];
        this[k] = v;
      }
    }
    return SimpleJob;
  })();
  JobRouteManager = (function() {
    function JobRouteManager(route) {
      this.jobs = [];
      this.archivedJobs = [];
      this.processRoute(null, route);
    }
    JobRouteManager.prototype.getJobData = function(route) {
      var clonedJob;
      clonedJob = _.extend({}, route);
      if (clonedJob.subjobs != null) {
        delete clonedJob.subjobs;
      }
      if (clonedJob.subjob != null) {
        delete clonedJob.subjob;
      }
      return clonedJob;
    };
    JobRouteManager.prototype.processRoute = function(parent, route) {
      var childJob, index, index2, j, j2, job, subjob, subjobs, _i, _len, _len2, _len3, _ref, _ref2;
      if (route instanceof Marker) {
        job = new Job();
        this.jobs.push(job);
        if (parent != null) {
          job.parentJobId = parent._id;
          job.status = "dependant";
          job.parentJobType = parent.type;
        } else {
          job.status = "ready_for_processing";
        }
        job.data = this.getJobData(route);
        if (route instanceof Par) {
          job.childCount = route.subjobs.length;
          job.type = "parallel";
          _ref = route.subjobs;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            j = _ref[_i];
            this.processRoute(job, j);
          }
        } else if (route instanceof Seq) {
          job.childCount = route.subjobs.length;
          job.type = "sequential";
          subjobs = [];
          _ref2 = route.subjobs;
          for (index = 0, _len2 = _ref2.length; index < _len2; index++) {
            j = _ref2[index];
            subjob = this.processRoute(job, j);
            subjob.index = index;
            subjobs.push(subjob);
          }
          for (index2 = 0, _len3 = subjobs.length; index2 < _len3; index2++) {
            j2 = subjobs[index2];
            if (index2 + 1 < subjobs.length) {
              j2.nextJobId = subjobs[index2 + 1]._id;
            }
          }
        } else if (route instanceof SimpleJob) {
          job.type = "job";
          if (route.subjob != null) {
            childJob = this.processRoute(job, route.subjob);
            if (childJob != null) {
              job.childJobId = childJob._id;
            }
          }
        }
        return job;
      }
    };
    JobRouteManager.prototype.saveJobs = function(callback) {
      this.callback = callback != null ? callback : (function() {});
      return this._saveJobs();
    };
    JobRouteManager.prototype._saveJobs = function() {
      var job, self;
      self = this;
      if (this.jobs.length === 0) {
        return this.callback();
      } else {
        job = this.jobs.shift();
        return job.save(function(err) {
          if (err) {
            self.callback(err);
          }
          self.archivedJobs.push(job);
          return self._saveJobs();
        });
      }
    };
    return JobRouteManager;
  })();
  module.exports = {
    Par: function(a) {
      return new Par(a);
    },
    Seq: function(a) {
      return new Seq(a);
    },
    SimpleJob: function(a) {
      return new SimpleJob(a);
    },
    JobRouteManager: JobRouteManager
  };
}).call(this);
