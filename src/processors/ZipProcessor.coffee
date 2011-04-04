
AbstractProcessor = require './AbstractProcessor'
spawn = require('child_process').spawn

class ZipProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      d = job.data
    
      compress = spawn 'tar', ['-cvvf', "#{d.output}/file-#{new Date().getTime()}.tar", d.output ]
    
      compress.on 'exit', (code) ->
        if code is 1 then errorHandler({errorMessage: "could not zip it"})
        nextHandler();
    else 
      errorHandler({errorMessage: "could not zip it"})
  
  
  
module.exports = ZipProcessor