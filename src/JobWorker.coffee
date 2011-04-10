AbstractJobManager  = require './AbstractJobManager'
async               = require 'async'
_                   = require("underscore")._
Job                 = require './domain/Job'
JobContext          = require "./domain/JobContext"
fs                  = require 'fs'
JobFlowManager      = require './JobFlowManager'

class JobWorker extends AbstractJobManager
  
  
  constructor:(@options)->
    super(@options)
    @jobFlowManager = new JobFlowManager()
    
  takeJob:(err)=>
    self = @
    #if err then console.log err
    
    @jobFlowManager.processNext (err, job) ->
      if err then console.log err
      if job?  
        #TODO: Add a processor cache
        try 
          processorClass = require "./processors/new/#{job.processor}Processor"          
        catch e
          console.log e.stack
                
        missingProcessor = ()->
          return self.jobFlowManager.jobErrored({retry:false,errorMessage:"could not find processor:#{job.processor}Processor"}, job, self.takeJob)
        
        unless processorClass?
          missingProcessor()
          
        JobContext.create job, (err, jobContext)->
          if err then console.log err
          
          processor = new processorClass(jobContext)
          
          unless processor?
            missingProcessor()
            
          successful = ->
            fs.readdir jobContext.getCurrentFolder(), (err, files)->
              files = files || []
              job.outputFiles = _.map files, (f) -> jobContext.getCurrentFolder() + f
              relativeFilePaths = _.map files, (f) -> jobContext.getRelativeCurrentFolder() + f
              jobContext.mediaItem.setGenerateOutputFiles job.jobPath, relativeFilePaths, (err)->
                console.log err if err
                self.jobFlowManager.jobSuccessful job, self.takeJob
          try 
            processor.process(
              job
              (errorOptions) -> self.jobFlowManager.jobErrored(errorOptions, job, self.takeJob)
              () -> setTimeout(successful,10)

            )
          catch e
            missingProcessor()
            console.log e.stack
          
             
      else
        #console.log "job queue empty"
        setTimeout self.takeJob, 10
  


module.exports = JobWorker

