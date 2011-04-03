JobManager = require './lib/JobManager.js'
fs = require 'fs'
util = require 'util'

jobManager = new JobManager({
  mongoURL:"mongodb://localhost/media_engine"
})

path = "/Users/joe/samples"

originalPath = "/Users/joe/tes-timages"

files = fs.readdirSync originalPath

fn = (job) -> console.log job._id 

files.forEach (f) ->
	
  jobManager.addJob({
    width:500
    input:originalPath + "/" + f
    output:path + "/thumbs"
    name: f
  }, fn)

	
