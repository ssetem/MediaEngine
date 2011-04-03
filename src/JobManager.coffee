
AbstractJobManager = require './AbstractJobManager'
require './domain/Job'


class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super @options
    
  addJob:(data, fn, options={})->
    j = new Job(options)
    j.data = data
    j.save (err) ->
       fn(err) if err
       fn(j)

module.exports = JobManager
