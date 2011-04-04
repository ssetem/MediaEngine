
AbstractJobManager = require './AbstractJobManager'
require './domain/Job'
{Par, Seq, SimpleJob,JobRouteManager} = require './domain/JobRoute'



class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super(@options)
    
  addJob:(data, fn, options={})->
    j = new Job(options)
    j.data = data
    j.save (err) ->
      fn(err) if err
      fn(j)
    j
  
  addJobRoute:(route)->
    new JobRouteManager(route).saveJobs()

module.exports = JobManager
