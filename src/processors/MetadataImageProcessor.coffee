
AbstractProcessor = require './AbstractProcessor'
FileUtils = require('../FileUtils');
im = require 'imagemagick'

class ImageMetadataProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    if job?.data?
      d = job.data
      
      im.readMetadata d.input, (err, metadata) ->
        if err?
          errorHandler({errorMessage:err.toString()})
        else
          getMetadata = (metadata, type) ->
            if metadata[type]?
              json = JSON.stringify metadata[type]
              fileName = "#{d.output}#{d.name}-#{type}.json" 
              
              FileUtils.writeFile fileName, json, (err) ->
               if (err) then errorHandler(err)
               nextHandler()
          
          getMetadata metadata, type for type in ["exif", "iptc"]
                     
    else
      errorHandler({errorMessage:"no data provided for image metadata"})
  
  
module.exports = ImageMetadataProcessor