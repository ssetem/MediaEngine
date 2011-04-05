JobWorker = require './lib/JobWorker.js'
JobManager = require './lib/JobManager.js'
FileUtils = require './lib/FileUtils.js'
MediaItem = require './lib/domain/MediaItem.js'
AbstractProcessor = require "./lib/processors/AbstractProcessor.js"
async = require 'async'
{Par, Seq, SimpleJob,JobRouteManager} = require "./lib/JobRouteManager"

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

jobWorkers = []



sampleJobs = []
for i in [1..2]
  sampleJobs.push new SimpleJob({processor:"TextProcessor", name:i})

# 
TEXT_ROUTE = SimpleJob
  name:"Job1"
  subjob:Seq([
    SimpleJob({ 
      processor:"TextProcessor", name:"text1"
      #subjob:SimpleJob(name:"hi", subjob:Par(sampleJobs))
    })
    SimpleJob({ 
      processor:"TextProcessor", name:"text2"
      subjob:Seq(sampleJobs)
    })
  ])



# TEXT_ROUTE = Seq([
#   Par([
#     SimpleJob({name:"thumbnails"})
#     SimpleJob({
#       name:"previews"
#       subjob: Par(sampleJobs)
#     })
#   ])
#   Seq([
#     SimpleJob({name:"s3"})
#     SimpleJob({name:"cloudfront"})
#   ])
# ])

class TextProcessor extends AbstractProcessor
    
  process:(job, errorHandler, nextHandler)->    
    #console.log("processing")
    #
    if new Date().getTime() %2 and false
      return errorHandler({retry:false})
    someId = @jobContext.mediaItem._id.toString()
    console.log()
    console.log "CURRENT", someId+@jobContext.job.jobPath
    console.log "PREVIOUS", someId+(@jobContext.previousJob?.jobPath || "/original/")
    # 
    # console.log()
    #nextHandler()
    #setTimeout(nextHandler, 0)
    # #nextHandler()
    #console.log "CURRENT_FOLDER", @jobContext.getCurrentFolder()
    #console.log "PREVIOUS_FOLDER", @jobContext.getPreviousFolder()
    # # console.log 
    # # console.log "/" + job.mediaItemId+job.jobPath
    # # 
    
    inputFiles = @jobContext.getInputFiles()
    console.log inputFiles.length
    jobContext = @jobContext
    async.forEach(
      inputFiles
      (f, next)->  
        FileUtils.copyFile(f, jobContext.getCurrentFolder()+"/output#{+new Date}.txt",next)
      nextHandler
    )

    

for i in [1]
  jw = new JobWorker({
    mongoURL:"mongodb://localhost/media_engine"
  })
  jw.processorClass = TextProcessor
  jobWorkers.push(jw)    

Job.collection.remove ->
  
  textFile =  __dirname + "/test/resources/lorem.txt"
  MediaItem.basePath= __dirname + "/filestore"
  MediaItem.saveFile textFile, (err, mediaItem)->
    if err then console.dir err.stack
    #console.log mediaItem
    for i in [1]
      jobManager.addJobRoute(TEXT_ROUTE, mediaItem)
    #jobManager.addJobRoute(TEXT_ROUTE, mediaItem)
    
  
   jobWorker.takeJob() for jobWorker in jobWorkers
   
