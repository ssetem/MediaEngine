FileUtils = require '../FileUtils'
fs = require 'fs'
class AbstractProcessor
  
  constructor:(@jobContext)->
  
  createOutputFolder:()->
    fs.mkdirSync(@jobContext.getCurrentFolder(), 0755)
    
  
module.exports = AbstractProcessor