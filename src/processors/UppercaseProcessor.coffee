
AbstractProcessor = require './AbstractProcessor'

# Sample processor to simply uppcase and log info on a job
class UppercaseProcessor extends AbstractProcessor
  
  constructor:->
    super()
  
  process:( job, errorHandler, nextHandler ) ->
    console.log job._id.toString().toUpperCase()
    if new Date().getTime() % 2
      nextHandler()
    else 
      errorHandler()
  
  
  
module.exports = UppercaseProcessor