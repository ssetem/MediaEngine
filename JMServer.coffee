JobManager = require './lib/JobManager.js'
fs = require 'fs'
util = require 'util'
{Par, Seq, SimpleJob,JobRouteManager} = require './lib/domain/JobRoute'

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

# path = "/Users/joe/samples"
# 
# originalPath = "/Users/joe/tes-timages"
# 
# files = fs.readdirSync originalPath
# 
# files.forEach (f) ->
#   
#   jobManager.addJob({
#     width:500
#     input:originalPath + "/" + f
#     output:path + "/thumbs/"+ f
#   })



TEXT_ROUTE = Par([
  SimpleJob({
    processor:"capitalise"
  }),
  SimpleJob({
    processor:"truncate", size:50
    subjob: new SimpleJob({
      processor:"capitalise"
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

jobManager.addJobRoute(TEXT_ROUTE)
