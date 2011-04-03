(function() {
  var AbstractJobManager, JobManager;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractJobManager = require('./AbstractJobManager');
  require('./domain/Job');
  JobManager = (function() {
    __extends(JobManager, AbstractJobManager);
    function JobManager(options) {
      this.options = options;
      JobManager.__super__.constructor.call(this, this.options);
    }
    JobManager.prototype.addJob = function(data, fn, options) {
      var j;
      if (options == null) {
        options = {};
      }
      j = new Job(options);
      j.data = data;
      return j.save(function(err) {
        if (err) {
          fn(err);
        }
        return fn(j);
      });
    };
    return JobManager;
  })();
  module.exports = JobManager;
}).call(this);
