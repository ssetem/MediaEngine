
AbstractProcessor = require './AbstractProcessor'

# Sample processor to simply uppcase and log info on a job
class UppercaseProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    setTimeout( ->
      console.log job._id.toString().toUpperCase()
      if new Date().getTime() % 3
        nextHandler()
      else 
        errorHandler({retry:false})
    ,1)
  
  
  
module.exports = UppercaseProcessor