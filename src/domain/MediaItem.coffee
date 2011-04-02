mongoose = require 'mongoose'

schema = new mongoose.Schema {
  
  creationDate: 
    type: Date
    default: Date.now
  
  lastModified:
    type: Date
    default: Date.now
  
  fileName:String

}

mongoose.model 'MediaItem', schema
