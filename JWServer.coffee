JobWorker = require './lib/JobWorker.js'
JobManager = require './lib/JobManager.js'

{Par, Seq, SimpleJob,JobRouteManager} = require './lib/domain/JobRoute'

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

jobWorkers = []

for i in [1..10]
  jobWorkers.push(new JobWorker({
    mongoURL:"mongodb://localhost/media_engine"
  }))



TEXT_ROUTE = Par([
  SimpleJob({
    processor:"capitalise"
  }),
  SimpleJob({
    processor:"truncate", size:50
    subjob: SimpleJob({
      processor:"capitalise"
    })
  }),
  SimpleJob({
    processor:"replace"
    regex:/(love)/
    replacement:"lovely"
    subjob:Par([
      SimpleJob({
        processor:"capitalise"
      }),
      SimpleJob({
        processor:"truncate", size:50
        subjob: SimpleJob({
          processor:"capitalise"
          subjob:Seq([
            SimpleJob({
              processor:"extract_exif"      
            }),
            SimpleJob({
              processor:"extract_iptc"      
            }),
            SimpleJob({
              processor:"solr_index"                
            })
          ])
        })
      }),
      SimpleJob({
        processor:"replace"
        regex:/(love)/
        replacement:"lovely"
      }),
      Seq([
        SimpleJob({
          processor:"extract_exif"      
        }),
        SimpleJob({
          processor:"extract_iptc"      
        }),
        SimpleJob({
          processor:"solr_index"                
        })
      ])
    ])
  }),
  Seq([
    SimpleJob({
      processor:"extract_exif"      
    }),
    SimpleJob({
      processor:"extract_iptc"      
    }),
    SimpleJob({
      processor:"solr_index"   
      subjob:Par([
        SimpleJob({
          processor:"capitalise"
        }),
        SimpleJob({
          processor:"truncate", size:50
          subjob: SimpleJob({
            processor:"capitalise"
          })
        }),
        SimpleJob({
          processor:"replace"
          regex:/(love)/
          replacement:"lovely"
          subjob:Par([
            SimpleJob({
              processor:"capitalise"
            }),
            SimpleJob({
              processor:"truncate", size:50
              subjob: SimpleJob({
                processor:"capitalise"
                subjob:Seq([
                  SimpleJob({
                    processor:"extract_exif"      
                  }),
                  SimpleJob({
                    processor:"extract_iptc"      
                  }),
                  SimpleJob({
                    processor:"solr_index"                
                  })
                ])
              })
            }),
            SimpleJob({
              processor:"replace"
              regex:/(love)/
              replacement:"lovely"
            }),
            Seq([
              SimpleJob({
                processor:"extract_exif"      
              }),
              SimpleJob({
                processor:"extract_iptc"      
              }),
              SimpleJob({
                processor:"solr_index"                
              })
            ])
          ])
        }),
        Seq([
          SimpleJob({
            processor:"extract_exif"      
          }),
          SimpleJob({
            processor:"extract_iptc"      
          }),
          SimpleJob({
            processor:"solr_index"      
          })
        ])
      ])   
    })
  ])
])

# TEXT_ROUTE = Seq([
#   SimpleJob({processor:1})
#   SimpleJob({processor:2})
#   SimpleJob({processor:3})
#   SimpleJob({processor:4})
#   SimpleJob({processor:5})
#   SimpleJob({processor:6})
#   SimpleJob({processor:7})
#   SimpleJob({processor:8})
#   SimpleJob({processor:9})
#   SimpleJob({processor:10})
# ])

Job.collection.remove ->

  jobWorker.takeJob() for jobWorker in jobWorkers

  jobManager.addJobRoute(TEXT_ROUTE)
