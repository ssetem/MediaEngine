
AbstractProcessor = require './AbstractProcessor'

# Sample processor to simply uppcase and log info on a job
class UppercaseProcessor extends AbstractProcessor
  
  process:( job, errorHandler, nextHandler ) ->
    setTimeout( ->
      if new Date().getTime() % 2 or true
       console.log job._id+" "+job.data.processor        
       nextHandler()
      else 
       errorHandler({retry:true})
    ,Math.round(Math.random()*0))
  
  
  
module.exports = UppercaseProcessor