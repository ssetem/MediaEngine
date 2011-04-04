AbstractJobManager = require './AbstractJobManager'
require './domain/Job'
{Par, Seq, SimpleJob,JobRouteManager} = require './domain/JobRoute'



class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    
  addJob:(data, options={})->
    j = new Job(options)
    j.data = data
    j.save (err) ->
      console.log j._id
    j
  
  addJobRoute:(route)->
    new JobRouteManager(route).saveJobs()
    
module.exports = JobManager

