AbstractProcessor = require '../AbstractProcessor'
fs = require('fs');
imageMagick = require 'imagemagick'
async = require 'async'

class ImageMetadataProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    self = this
    if job?.data?
      data = job.data
      
      inputFile = @jobContext.getInputFiles()[0]
      
      this.createOutputFolder()
      
      imageMagick.readMetadata inputFile, (err, metadata) ->
        if err?
          errorHandler({errorMessage:err.toString()})
        else
          
          getMetadata = (type, next) ->
            if metadata[type]?
              json = JSON.stringify metadata[type], null, '\t'
              outputFile = "#{self.jobContext.getCurrentFolder()}/#{type}.json" 
              
              fs.writeFile outputFile, json, (err) ->
                next(err)
            else
              next(null)
              
          async.parallel(
            [
              (next)-> getMetadata('exif', next)
              (next)-> getMetadata('iptc', next)
            ]
            (err) ->
              if err then errorHandler({errorMessage:err.toString()})
              nextHandler()
          )
                     
    else
      errorHandler({errorMessage:"no data provided for image metadata"})
  
  
module.exports = ImageMetadataProcessor