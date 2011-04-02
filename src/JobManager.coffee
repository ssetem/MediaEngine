AbstractJobManager = require './AbstractJobManager'
fs = require 'fs'
util = require 'util'
require './domain/Job'


class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super @options
    
  addJob:(data)->
    j = new Job()
    j.data = data
    j.save (err) =>
      console.log 'adding new job:' + j._id
    
jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

path = "/Users/ash/Documents/MEE/MediaEngine/sample"

originalPath = "/Users/ash/joe-test-images"

files = fs.readdirSync originalPath

for f in files
  jobManager.addJob({
    width:50
    input:originalPath + "/" + f
    output:path + "/thumbs/"+ f
  })

