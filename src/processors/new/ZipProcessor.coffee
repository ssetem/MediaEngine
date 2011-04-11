
AbstractProcessor = require '../AbstractProcessor'
spawn = require('child_process').spawn

class ZipProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      data = job.data
      
      currentFolderPath = @jobContext.getCurrentFolder()
            
      zipFiles = @jobContext.getInputFiles().join(" ")
            
      this.createOutputFolder()    
      
      #FIXME: needs to remove the absolute paths
      compress = spawn 'zip', ['-r', "#{currentFolderPath}file-#{new Date().getTime()}", zipFiles ], {cwd: currentFolderPath}
                            
      compress.on 'exit', (code) ->
        if code is 1 
         errorHandler({errorMessage: "could not zip it " })
        else
         nextHandler()

    else 
      errorHandler({errorMessage: "could not zip it"})
  
  
  
module.exports = ZipProcessor