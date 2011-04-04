AbstractJobManager = require './AbstractJobManager'
UppercaseProcessor = require './processors/UppercaseProcessor'
DataPrinter = require './processors/DataPrinter'
ImageMagickProcessor = require './processors/ImageMagickProcessor'
JobFlowManager = require './JobFlowManager'

require './domain/Job'


class JobWorker extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    #@processor = new ImageMagickProcessor()
    @processor = new UppercaseProcessor()
    @jobFlowManager = new JobFlowManager
    
  takeJob:(err)=>
    self = @
    #if err then console.log err
    
    @jobFlowManager.processNext (err, job) ->
      if err then console.log err
      if job?
        return self.processor.process(
          job,
          
          #when job fails
          (errorOptions) -> 
            self.jobFlowManager.jobErrored(errorOptions, job, self.takeJob)
          ,      
          #when job completes
          ()->
            self.jobFlowManager.jobSuccessful job, self.takeJob
        )        
      else
        #console.log "job queue empty"
        setTimeout self.takeJob, 1000
  


module.exports = JobWorker

