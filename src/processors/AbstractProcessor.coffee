class AbstractProcessor
  
  #default implementation
  process:(job, errorHandler, nextHandler)->
    errorHandler({errorMessage:"unimplemented processor"})

module.exports = AbstractProcessor