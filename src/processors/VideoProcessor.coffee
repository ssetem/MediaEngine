
AbstractProcessor = require './AbstractProcessor'

class VideoProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      d = job.data
      ffmpeg.mp4 d.input, d.output+d.file, (err, out, code)->
        console.log arguments
        if code is 2 then errorHandler({errorMessage: "ouch"})
        nextHandler();
      
    else 
      errorHandler({errorMessage: "could not video it"})
  
  
  
module.exports = VideoProcessor