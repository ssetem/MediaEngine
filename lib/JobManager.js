(function() {
  var AbstractJobManager, JobManager, f, files, fs, jobManager, originalPath, path, util, _i, _len;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  AbstractJobManager = require('./AbstractJobManager');
  fs = require('fs');
  util = require('util');
  require('./domain/Job');
  JobManager = (function() {
    __extends(JobManager, AbstractJobManager);
    function JobManager(options) {
      this.options = options;
      JobManager.__super__.constructor.call(this, this.options);
    }
    JobManager.prototype.addJob = function(data, options) {
      var j;
      if (options == null) {
        options = {};
      }
      j = new Job(options);
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
  path = "/Users/ash/Documents/MEE/MediaEngine/sample";
  originalPath = "/Users/ash/joe-test-images";
  files = fs.readdirSync(originalPath);
  for (_i = 0, _len = files.length; _i < _len; _i++) {
    f = files[_i];
    jobManager.addJob({
      width: 500,
      input: originalPath + "/" + f,
      output: path + "/thumbs/" + f
    });
  }
}).call(this);
