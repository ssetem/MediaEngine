
AbstractProcessor = require './AbstractProcessor'
util = require 'util'

# Sample processor to simply uppcase and log info on a job
class ImageMetadataProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    if job?.data?
      console.log job.data
      nextHandler()
    else
      errorHandler({retry:true})
  
  
module.exports = ImageMetadataProcessor