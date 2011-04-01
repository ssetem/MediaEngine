AbstractJobManager = require './AbstractJobManager'
UppercaseProcessor = require './processors/UppercaseProcessor'
DataPrinter = require './processors/DataPrinter'

require './domain/Job'


class JobWorker extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    @processor = new DataPrinter()

  takeJob:=>
    self = @
    
    Job.processNext (err, job) ->
      if job?
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
      job[errorMethod] ->
        console.log "job: #{job._id} errored, status:#{job.status}, retryCount:#{job.retryCount}"
        self.takeJob()
  
  createCompletedCallback:(job)->
    self = @
    return ->
      console.log "job: #{job._id} completed"
      job.complete(self.takeJob)

    
jobWorker = new JobWorker({
  mongoURL:"mongodb://localhost/media_engine"
})

jobWorker.takeJob()
