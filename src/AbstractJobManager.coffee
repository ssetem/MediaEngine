require.paths.unshift(__dirname+'/node_modules')

mongoose = require 'mongoose'
utils    = require 'util'
require './domain/Job'


class AbstractJobManager
  
  constructor:(@options)->
    @initMongo()
  
  initMongo:->
    @db = mongoose.connect @options.mongoURL
    global.Job = mongoose.model 'Job'


module.exports = AbstractJobManager
