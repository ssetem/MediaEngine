(function() {
  var JobWorker, jobWorker;
  JobWorker = require('./lib/JobWorker.js');
  jobWorker = new JobWorker({
    mongoURL: "mongodb://localhost/media_engine"
  });
  jobWorker.takeJob();
}).call(this);
