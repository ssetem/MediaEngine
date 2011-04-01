require.paths.unshift(__dirname+'/node_modules')

mongoose = require 'mongoose'
util    = require 'util'
UppercaseProcessor = require './processors/UppercaseProcessor'


require './domain/Job'


class WorkerManager
  
  constructor:(@options)->
    @initMongo()
    @processor = new UppercaseProcessor()
  
  initMongo:->
    @db = mongoose.connect @options.mongoURL
    global.Job = mongoose.model 'Job'

  takeJob:=>
    self = @
    
    Job.pop (err, job) ->
      if job?
        console.log "got unprocessed #{job._id}"
        self.takeJob()
      else 
        console.log "job queue empty"
        setTimeout self.takeJob, 1000

  errorHandler:->
    console.log "something went wrong :o"
    
workerManager = new WorkerManager({
  mongoURL:"mongodb://localhost/media_engine"
})

workerManager.takeJob()
