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


IMAGE_ROUTE = Par([
  SimpleJob({
    processor:"Image", name:"thumb", width:100
  })
  SimpleJob({
    processor:"Image", name:"preview", width:300#, customArgs:["-gaussian-blur", "20"]
    subjob:SimpleJob({processor:"Image", name:"rotate", width:200, customArgs:["-rotate","180"]})
  })
  SimpleJob({
    processor:"ImageMetadata", name:"metadata"
  })
])


MediaItem.collection.remove ->
  Job.collection.remove ->
  
    MediaItem.basePath= __dirname + "/filestore"
  
    imagefolder = __dirname + "/test/resources/images"
    #imagefolder =  "/Users/ash/joe-test-images"
  
  
    queue = async.queue(
      (f, next) ->
        MediaItem.saveFile f, (err, mediaItem)->
          if err then console.dir err.stack
          jobManager.addJobRoute(IMAGE_ROUTE, mediaItem)
          next()
      #number of workers
      10
    )
    
    empty = ()->
  
    FileUtils.readdirFullpath imagefolder, (err, files)->
      if err then console.log err
    
      for f in files
        queue.push(f, empty)
