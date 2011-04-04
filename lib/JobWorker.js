(function() {
  var AbstractJobManager, ImageMagickProcessor, JobFlowManager, JobWorker, MetadataImageProcessor, UppercaseProcessor, VideoProcessor, ZipProcessor;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  AbstractJobManager = require('./AbstractJobManager');
  UppercaseProcessor = require('./processors/UppercaseProcessor');
  ImageMagickProcessor = require('./processors/ImageMagickProcessor');
  JobFlowManager = require('./JobFlowManager');
  MetadataImageProcessor = require('./processors/MetadataImageProcessor');
  ZipProcessor = require('./processors/ZipProcessor');
  VideoProcessor = require('./processors/VideoProcessor');
  require('./domain/Job');
  JobWorker = (function() {
    __extends(JobWorker, AbstractJobManager);
    function JobWorker(options) {
      this.options = options;
      this.takeJob = __bind(this.takeJob, this);;
      JobWorker.__super__.constructor.call(this, this.options);
      this.processor = new VideoProcessor();
      this.jobFlowManager = new JobFlowManager;
    }
    JobWorker.prototype.takeJob = function(err) {
      var self;
      self = this;
      return this.jobFlowManager.processNext(function(err, job) {
        if (err) {
          console.log(err);
        }
        if (job != null) {
          return self.processor.process(job, function(errorOptions) {
            return self.jobFlowManager.jobErrored(errorOptions, job, self.takeJob);
          }, function() {
            return self.jobFlowManager.jobSuccessful(job, self.takeJob);
          });
        } else {
          return setTimeout(self.takeJob, 1000);
        }
      });
    };
    return JobWorker;
  })();
  module.exports = JobWorker;
}).call(this);
