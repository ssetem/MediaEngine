(function() {
  var JobManager, files, fn, fs, jobManager, originalPath, path, util;
  JobManager = require('./lib/JobManager.js');
  fs = require('fs');
  util = require('util');
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  path = "/Users/joe/samples";
  originalPath = "/Users/joe/tes-timages";
  files = fs.readdirSync(originalPath);
  fn = function(job) {
    return console.log(job._id);
  };
  files.forEach(function(f) {
    return jobManager.addJob({
      width: 500,
      input: originalPath + "/" + f,
      output: path + "/thumbs",
      name: f
    }, fn);
  });
}).call(this);
