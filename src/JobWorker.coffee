AbstractJobManager = require './AbstractJobManager'

UppercaseProcessor = require './processors/UppercaseProcessor'
ImageMagickProcessor = require './processors/ImageMagickProcessor'
JobFlowManager = require './JobFlowManager'
MetadataImageProcessor = require './processors/MetadataImageProcessor'
ZipProcessor = require './processors/ZipProcessor'
VideoProcessor = require './processors/VideoProcessor'
async = require 'async'
_ = require("underscore")._
require './domain/Job'
JobContext = require "./domain/JobContext"
fs = require 'fs'

class JobWorker extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    #@processor = new ImageMagickProcessor()
    #@processor = new UppercaseProcessor()
    #@processor = new VideoProcessor()
    @processClass = UppercaseProcessor
    @jobFlowManager = new JobFlowManager()
    
  takeJob:(err)=>
    self = @
    #if err then console.log err
    
    @jobFlowManager.processNext (err, job) ->
      if err then console.log err
      if job?
        JobContext.create job, (err, jobContext)->
          if err then console.log err
          processor = new self.processorClass(jobContext)
          
          successful = ->
            fs.readdir jobContext.getCurrentFolder(), (err, files)->
              files = files || []
              job.outputFiles = _.map files, (f) -> jobContext.getCurrentFolder() + f
              self.jobFlowManager.jobSuccessful job, self.takeJob
      
          processor.process(
            job
            (errorOptions) -> self.jobFlowManager.jobErrored(errorOptions, job, self.takeJob)
            () -> setTimeout(successful,10)

          )
             
      else
        #console.log "job queue empty"
        setTimeout self.takeJob, 10
  


module.exports = JobWorker

