JobManager = require './lib/JobManager.js'
fs = require 'fs'
util = require 'util'
{Par, Seq, SimpleJob,JobRouteManager} = require './lib/JobRouteManager'
FileUtils = require './lib/FileUtils'
Job = require './lib/domain/job'
MediaItem = require './lib/domain/MediaItem'

async = require 'async'

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

###
IMAGE_ROUTE = Par([
  SimpleJob({
    processor:"Image", name:"thumb", width:100
  })
  SimpleJob({
    processor:"Image", name:"preview", width:700 #, customArgs:["-gaussian-blur", "20"]
    subjob:SimpleJob({
      processor:"Image", name:"rotate", width:700, customArgs:["-rotate","180"]
      subjob:SimpleJob({processor:"Image", name:"rotate_again", width:700, customArgs:["-rotate", "180"]})
    })
  })
  SimpleJob({
    processor:"ImageMetadata", name:"metadata"
  })
])

###

IMAGE_ROUTE = Par([
  SimpleJob({
    processor: "Video", name:"flv", args: "-s 352x240 -b 512k -acodec copy"
  })
])

FileUtils.rmdirSyncRecursive __dirname + "/filestore"


MediaItem.collection.remove ->
  Job.collection.remove ->
  
    MediaItem.basePath= __dirname + "/filestore"
  
    imagefolder = __dirname + "/test/resources/video"
    #imagefolder =  "/Users/ash/joe-test-images"
    #imagefolder = "/Users/ash/Pictures"
  
    queue = async.queue(
      (f, next) ->
        MediaItem.saveFile f, (err, mediaItem)->
          if err 
            console.dir err.stack            
          else
            jobManager.addJobRoute(IMAGE_ROUTE, mediaItem)
          
          next()
      #number of workers
      20
    )
    
    empty = ()->
  
    FileUtils.readdirFullpath imagefolder, (err, files)->
      if err then console.log err
    
      for f in files
        queue.push(f, empty)
