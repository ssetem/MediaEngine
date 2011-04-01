require.paths.unshift(__dirname+'/node_modules')

mongoose = require 'mongoose'
redis    = require 'redis'
utils    = require 'util'
UppercaseProcessor = require './processors/UppercaseProcessor'


require './domain/Job'


class WorkerManager
  
  constructor:(@options)->
    @initMongo()
    @initRedis()
    @processor = new UppercaseProcessor()
  
  initMongo:->
    @db = mongoose.connect @options.mongoURL
    global.Job = mongoose.model 'Job'

  initRedis:->
    @redisClient = redis.createClient()

  takeJob:=>
    self = @
    @redisClient.rpop 'media_engine.jobs', (err, jobId) ->
      if jobId?
        #get job from mongodb
        console.log "got job with id of: #{jobId}"        
        Job.findById jobId, (err, job) ->
          self.processor.process(job, self.errorHandler, self.takeJob )
      else
        setTimeout self.takeJob, 10
    
  errorHandler:->
    console.log "something went wrong :o"
    
workerManager = new WorkerManager({
  mongoURL:"mongodb://localhost/media_engine"
  redisURL:'localhost'
})

workerManager.takeJob()
