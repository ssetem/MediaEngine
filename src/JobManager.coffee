AbstractJobManager = require './AbstractJobManager'
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

setInterval( ->
  jobManager.addJob({
    x:120
    y:600
  })
,200
)
