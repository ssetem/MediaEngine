AbstractProcessor = require './AbstractProcessor'
util = require 'util'
im = require 'imagemagick'


# Sample processor to simply uppcase and log info on a job
class ImageMagickProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    if job?.data?
      d = job.data
      params = {  srcPath: d.input,  dstPath: d.output,  width:   d.width  	}
      
      im.resize params, (err, stdout, stderr) ->
    	  if err
    	    errorHandler({errorMessage:err.toString()})
    	  else
    	    console.log stdout
    	    nextHandler()
    	
  
  
module.exports = ImageMagickProcessor
