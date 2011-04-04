(function() {
  var JobManager, JobRouteManager, JobWorker, Par, Seq, SimpleJob, TEXT_ROUTE, i, jobManager, jobWorkers, _ref;
  JobWorker = require('./lib/JobWorker.js');
  JobManager = require('./lib/JobManager.js');
  _ref = require('./lib/domain/JobRoute'), Par = _ref.Par, Seq = _ref.Seq, SimpleJob = _ref.SimpleJob, JobRouteManager = _ref.JobRouteManager;
  jobManager = new JobManager({
    mongoURL: "mongodb://localhost/media_engine"
  });
  jobWorkers = [];
  for (i = 1; i <= 10; i++) {
    jobWorkers.push(new JobWorker({
      mongoURL: "mongodb://localhost/media_engine"
    }));
  }
  TEXT_ROUTE = Par([
    SimpleJob({
      processor: "capitalise"
    }), SimpleJob({
      processor: "truncate",
      size: 50,
      subjob: SimpleJob({
        processor: "capitalise"
      })
    }), SimpleJob({
      processor: "replace",
      regex: /(love)/,
      replacement: "lovely",
      subjob: Par([
        SimpleJob({
          processor: "capitalise"
        }), SimpleJob({
          processor: "truncate",
          size: 50,
          subjob: SimpleJob({
            processor: "capitalise",
            subjob: Seq([
              SimpleJob({
                processor: "extract_exif"
              }), SimpleJob({
                processor: "extract_iptc"
              }), SimpleJob({
                processor: "solr_index"
              })
            ])
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
      ])
    }), Seq([
      SimpleJob({
        processor: "extract_exif"
      }), SimpleJob({
        processor: "extract_iptc"
      }), SimpleJob({
        processor: "solr_index",
        subjob: Par([
          SimpleJob({
            processor: "capitalise"
          }), SimpleJob({
            processor: "truncate",
            size: 50,
            subjob: SimpleJob({
              processor: "capitalise"
            })
          }), SimpleJob({
            processor: "replace",
            regex: /(love)/,
            replacement: "lovely",
            subjob: Par([
              SimpleJob({
                processor: "capitalise"
              }), SimpleJob({
                processor: "truncate",
                size: 50,
                subjob: SimpleJob({
                  processor: "capitalise",
                  subjob: Seq([
                    SimpleJob({
                      processor: "extract_exif"
                    }), SimpleJob({
                      processor: "extract_iptc"
                    }), SimpleJob({
                      processor: "solr_index"
                    })
                  ])
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
            ])
          }), Seq([
            SimpleJob({
              processor: "extract_exif"
            }), SimpleJob({
              processor: "extract_iptc"
            }), SimpleJob({
              processor: "solr_index"
            })
          ])
        ])
      })
    ])
  ]);
  Job.collection.remove(function() {
    var jobWorker, _i, _len;
    for (_i = 0, _len = jobWorkers.length; _i < _len; _i++) {
      jobWorker = jobWorkers[_i];
      jobWorker.takeJob();
    }
    return jobManager.addJobRoute(TEXT_ROUTE);
  });
}).call(this);
