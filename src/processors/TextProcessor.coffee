
AbstractProcessor = require './AbstractProcessor'

class TextProcessor extends AbstractProcessor
  
  constructor:(@job)->
    super(@job)
  
  process:( job, errorHandler, nextHandler ) ->
    
    if job?.data?
      nextHandler();
    else 
      errorHandler({errorMessage: "could not text process job"})
  
  
  
module.exports = TextProcessor