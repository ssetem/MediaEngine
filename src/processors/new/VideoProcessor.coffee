
AbstractProcessor = require '../AbstractProcessor'
spawn = require('child_process').spawn

class VideoProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      data = job.data
      
      this.createOutputFolder()    
      
      #FIXME: handle more than one input
      file = @jobContext.getInputFiles()[0].replace(' ', '\ ')
      currentFolderPath = @jobContext.getCurrentFolder()
      args = "-i #{file} #{data.args} #{currentFolderPath}output.flv".split(" ")
                        
      ffmpeg = spawn 'ffmpeg', args
      
      ffmpeg.stdout.on 'data', (data) -> 
        console.log('stdout: ' + data)

      ffmpeg.stderr.on 'data', (data) ->
        console.log('stderr: ' + data)

      ffmpeg.on 'exit', (code) ->
        if code is 1 then errorHandler({errorMessage: "could not video it"})
        nextHandler()
                 
    else 
      errorHandler({errorMessage: "could not video it"})
  
module.exports = VideoProcessor