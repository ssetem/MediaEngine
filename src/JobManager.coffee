AbstractJobManager = require './AbstractJobManager'
require './domain/Job'


class JobManager extends AbstractJobManager
  
  constructor:(@options)->
    super @options
    
  addJob:(data, options={})->
    j = new Job(options)
    j.data = data
    j.save (err) ->
      console.log j._id



	
    
module.exports = JobManager

