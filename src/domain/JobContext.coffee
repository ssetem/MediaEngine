async = require 'async'
Job = require "./Job"
MediaItem = require "./MediaItem"

String::getExtension = ()->
  this.replace /^.+(\.\w+)$/, "$1"

class JobContext
  
  
  constructor:(@job, @previousJob, @mediaItem)->
    #console.log arguments
    @folderPath = @mediaItem.getFolderPath()
  
    
  #static
  @create:(job, callback)->
    loadObjects = {          
      previousJob:(next)-> Job.findById job.previousJobId, next
      mediaItem:(next)->  MediaItem.findById job.mediaItemId, next                 
    }
    
    async.parallel loadObjects, (err, results)->

      if err 
        console.log err
        callback err
      
      {previousJob, mediaItem} = results      
      jobContext = new JobContext(job, previousJob, mediaItem)
      callback( null, jobContext )
    
  getInputFiles:()->
    if @previousJob?
      return @previousJob.outputFiles.concat()
    else if @mediaItem?
      return [@mediaItem.getFilePath()]
    else
      []
  
  getRelativeCurrentFolder:()->
    "#{@mediaItem.getRelativeFolderPath()}#{@job.jobPath}"
    
  getCurrentFolder:()->
    "#{@folderPath}#{@job.jobPath}"
  
  
  getPreviousFolder:()->
    if @previousJob?
      "#{@folderPath}#{@previousJob.jobPath}"
    else
      "#{@folderPath}/original"
      


module.exports = JobContext    
  