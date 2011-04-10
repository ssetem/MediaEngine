
AbstractProcessor = require '../AbstractProcessor'
spawn = require('child_process').spawn

class VideoProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      data = job.data
      
      #FIXME: handle more than one input
      file = @jobContext.getInputFiles()[0]
      currentFolderPath = @jobContext.getCurrentFolder()
      
      console.log data

      ffmpeg = spawn 'ffmpeg', ["-i #{file} #{data.args} #{currentFolderPath}output.flv" ]
      
      console.log "-i #{file}"+ " #{data.args}"+ " #{currentFolderPath}output.flv"
      
      ffmpeg.stdout.on 'data', (code) ->
         console.log code
         
      ffmpeg.stderr.on 'data', (code) ->
        console.log code
                
      ffmpeg.on 'exit', (code) ->
        if code is 1 
         #errorHandler({errorMessage: "could not video it " })
        else
         nextHandler()

    else 
      errorHandler({errorMessage: "could not video cit"})
  
  
  
module.exports = VideoProcessor