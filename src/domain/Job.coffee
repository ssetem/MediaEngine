mongoose = require 'mongoose'

schema = new mongoose.Schema {
  
  creationDate: 
    type: Date
    default: Date.now
  
  priority:
    type: Number
    default: 5
    index:true
    
  status:
    type: String,
    enum: ["unprocessed", "processing", "retrying", "completed"]
    default: "unprocessed"
    index:true
  
  retryCount:
    type:Number
    default:0
}
  
schema.static {
  
  pop:(func)->
    self = @
    filter = {status:"unprocessed"}
    sort = [["priority", 1]]
    update =  {"$set":{status: "processing"}}
    
    this.collection.findAndModify(filter,sort, update,(err, job) ->
      if job?._id?
        self.findById(job._id, func)    
      else
        func(null,null)
    )

}  
  
mongoose.model 'Job', schema