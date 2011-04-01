mongoose = require 'mongoose'

schema = new mongoose.Schema {
  
  creationDate: 
    type: Date
    default: Date.now
  
  priority:
    type: Integer
    default: 5
  
  status:
    type: String,
    enum: ["unprocessed", "processing", "retrying", "completed"]
    default: "unprocessed"
  
  retryCount:
    type:Integer,
    default:0
}
  
mongoose.model 'Job', schema