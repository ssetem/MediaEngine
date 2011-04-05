AbstractProcessor = require '../AbstractProcessor'
imageMagick = require 'imageMagick'
fs = require 'fs'
async = require 'async'

class ImageProcessor extends AbstractProcessor
    
    process:(job,errorHandler, nextHandler)->
      
      if @jobContext.mediaItem.extension is ".jpg" and job?.data?
        data = job.data
        width = data.width || 50
        inputFile = @jobContext.getInputFiles()[0]
        imageMagickParams = 
          srcPath:inputFile
          dstPath:@jobContext.getCurrentFolder()+"output.jpg"
          width:width
          customArgs:job.data.customArgs || []

        this.createOutputFolder()
        
        
        
        imageMagick.resize imageMagickParams, (err, stdout, stderr)->
          if err?
            errorHandler({errorMessage:err.toString()})
          else
            nextHandler()
      

      else
        errorHandler({errorMessage:"no data provided for image conversion"})
        

module.exports = ImageProcessor