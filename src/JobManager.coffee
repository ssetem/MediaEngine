
AbstractJobManager = require './AbstractJobManager'
require './domain/Job'
{Par, Seq, SimpleJob,JobRouteManager} = require './JobRouteManager'



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
  
  addJobRoute:(route, mediaItem)->
    console.log "Adding job route for #{mediaItem._id}"
    new JobRouteManager(route, mediaItem).saveJobs()

module.exports = JobManager
