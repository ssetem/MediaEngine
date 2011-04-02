AbstractJobManager = require './AbstractJobManager'
fs = require 'fs'
util = require 'util'
require './domain/Job'


class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super @options
    
  addJob:(data, options={})->
    j = new Job(options)
    j.data = data
    j.save (err) =>
      console.log 'adding new job:' + j._id
    
jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})
# 
# for i in [1..300]
#   p = (i % 5)+1
#   jobManager.addJob({}, {priority:p})

path = "/Users/ash/Documents/MEE/MediaEngine/sample"

originalPath = "/Users/ash/joe-test-images"

#originalPath = path + "/originals"

files = fs.readdirSync originalPath

for f in files
  jobManager.addJob({
    width:500
    input:originalPath + "/" + f
    output:path + "/thumbs/"+ f
  })

