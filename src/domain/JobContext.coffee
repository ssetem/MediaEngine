async = require 'async'
Job = require "./Job"
MediaItem = require "./MediaItem"


class JobContext
  
  
  constructor:(@job, @previousJob, @mediaItem)->
    @folderPath = @mediaItem.getFolderPath()
  
    
  #static
  @create:(job, callback)->
    loadObjects = {          
      previousJob:(next)-> Job.findById job.previousJobId, next
      mediaItem:(next)->  MediaItem.findById job.mediaItemId, next                 
    }
    
    async.parallel loadObjects, (err, results)->
      if err then callback err
      {previousJob, mediaItem} = results      
      jobContext = new JobContext(job, previousJob, mediaItem)
      callback( null, jobContext )
    
  
  getCurrentFolder:()->
    "#{@folderPath}#{@job.jobPath}"
  
  
  getPreviousFolder:()->
    if @previousJob?
      "#{@folderPath}#{@previousJob.jobPath}"
    else
      "#{@folderPath}/original"
      


module.exports = JobContext    
  