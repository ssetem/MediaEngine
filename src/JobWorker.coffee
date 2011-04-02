AbstractJobManager = require './AbstractJobManager'
UppercaseProcessor = require './processors/UppercaseProcessor'
DataPrinter = require './processors/DataPrinter'
ImageMagickProcessor = require './processors/ImageMagickProcessor'

require './domain/Job'


class JobWorker extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    @processor = new ImageMagickProcessor()
    #@processor = new UppercaseProcessor()
    
    
  takeJob:=>
    self = @
    
    Job.processNext (err, job) ->
      if job?
        console.log "processing job with priority:#{job.priority}"
        self.processor.process(
          job,
          self.createErrorCallback(job),
          self.createCompletedCallback(job)
        )
      else 
        console.log "job queue empty"
        setTimeout self.takeJob, 1000
  
  createErrorCallback:(job)->
    self = @
    return (errorOptions)->
      errorMethod = if errorOptions?.retry is false then "fail" else "retry"
    
      job[errorMethod] errorOptions?.errorMessage, ->
        console.log "job: #{job._id} errored, status:#{job.status}, retryCount:#{job.retryCount} "
        console.log job.errorMessage if job.errorMessage
        self.takeJob()
  
  createCompletedCallback:(job)->
    self = @
    return ->
      console.log "job: #{job._id} completed"
      job.complete(self.takeJob)

module.exports = JobWorker

