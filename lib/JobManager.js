(function() {
  var AbstractJobManager, JobManager, jobManager;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  AbstractJobManager = require('./AbstractJobManager');
  require('./domain/Job');
  JobManager = (function() {
    __extends(JobManager, AbstractJobManager);
    function JobManager(options) {
      this.options = options;
      JobManager.__super__.constructor.call(this, this.options);
    }
    JobManager.prototype.addJob = function(data) {
      var j;
      j = new Job();
      j.data = data;
      return j.save(__bind(function(err) {
        return console.log('adding new job:' + j._id);
      }, this));
    };
    return JobManager;
  })();
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  setInterval(function() {
    return jobManager.addJob({
      x: 120,
      y: 600
    });
  }, 200);
}).call(this);
