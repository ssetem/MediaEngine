require.paths.unshift(__dirname+'/node_modules')

mongoose = require 'mongoose'
utils    = require 'util'
require './domain/Job'



class JobManager
  
  constructor:(@options)->
    @initMongo()
  
  initMongo:->
    @db = mongoose.connect @options.mongoURL
    global.Job = mongoose.model 'Job'

  addJob:->
    j = new Job()
    j.save (err)=>
      console.log 'adding new job:' + j._id
    
jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

for i in [1..50]
  jobManager.addJob()
