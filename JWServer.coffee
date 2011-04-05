JobWorker = require './lib/JobWorker.js'
JobManager = require './lib/JobManager.js'
FileUtils = require './lib/FileUtils.js'
MediaItem = require './lib/domain/MediaItem.js'
AbstractProcessor = require "./lib/processors/AbstractProcessor.js"
async = require 'async'
fs = require 'fs'
{Par, Seq, SimpleJob,JobRouteManager} = require "./lib/JobRouteManager"

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

jobWorkers = []



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



    
FileUtils.rmdirSyncRecursive(__dirname + "/filestore")   

for i in [1..2]
  jw = new JobWorker({
    mongoURL:"mongodb://localhost/media_engine"
  })
  jobWorkers.push(jw)    

MediaItem.collection.remove ->
  Job.collection.remove ->
  
    textFile =  __dirname + "/test/resources/lorem.txt"
    MediaItem.basePath= __dirname + "/filestore"
  
    #imagefolder = __dirname + "/test/resources/images"
    imagefolder =  "/Users/ash/joe-test-images"
  
  
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

      
    
  
    jobWorker.takeJob() for jobWorker in jobWorkers
   
