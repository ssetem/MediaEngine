
AbstractProcessor = require './AbstractProcessor'

# Sample processor to simply uppcase and log info on a job
class UppercaseProcessor extends AbstractProcessor
  
  constructor:->
    super()
  
  process:( job, errorHandler, nextHandler ) ->
    console.log job._id.toString().toUpperCase()
    nextHandler()
  
  
  
  
module.exports = UppercaseProcessor