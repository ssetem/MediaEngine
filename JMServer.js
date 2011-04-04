(function() {
  var JobManager, JobRouteManager, Par, Seq, SimpleJob, TEXT_ROUTE, fs, jobManager, util, _ref;
  JobManager = require('./lib/JobManager.js');
  fs = require('fs');
  util = require('util');
  _ref = require('./lib/domain/JobRoute'), Par = _ref.Par, Seq = _ref.Seq, SimpleJob = _ref.SimpleJob, JobRouteManager = _ref.JobRouteManager;
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  TEXT_ROUTE = Par([
    SimpleJob({
      processor: "capitalise"
    }), SimpleJob({
      processor: "truncate",
      size: 50,
      subjob: new SimpleJob({
        processor: "capitalise"
      })
    }), SimpleJob({
      processor: "replace",
      regex: /(love)/,
      replacement: "lovely"
    }), Seq([
      SimpleJob({
        processor: "extract_exif"
      }), SimpleJob({
        processor: "extract_iptc"
      }), SimpleJob({
        processor: "solr_index"
      })
    ])
  ]);
  jobManager.addJobRoute(TEXT_ROUTE);
}).call(this);
