require.paths.unshift(__dirname+'/node_modules')

mongoose = require 'mongoose'
utils    = require 'util'
require './domain/Job'
events = require 'events'


class AbstractJobManager extends events.EventEmitter
  
  constructor:(@options)->
    super()
    @initMongo()
  
  initMongo:->
    @db = mongoose.connect @options.mongoURL
    global.Job = mongoose.model 'current_job'


module.exports = AbstractJobManager
