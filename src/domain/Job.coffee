mongoose = require 'mongoose'

schema = new mongoose.Schema {
  
  creationDate: 
    type: Date
    default: Date.now
  
  lastModified:
    type: Date
    default: Date.now
  
  priority:
    type: Number
    default: 5
    index:true
    
  status:
    type: String,
    enum: ["unprocessed", "processing", "retrying", "completed", "failed"]
    default: "unprocessed"
    index:true
  
  errorMessage:String
  
  #accepts any object
  data:{}
  
  retryCount:
    type:Number
    default:0
}

schema.method {
  
  complete :(func)->
    this.status = "completed"
    this.save(func)
  
  retry:(@errorMessage,func) ->
    if this.retryCount < 3
      this.status = "retrying"
      this.retryCount++
    else
      this.status = "failed"
    this.save func
  
  fail: (@errorMessage,func) ->
    this.status = "failed"
    this.save func
}
  
schema.static {
  
    
  processNext:(func)->
    self = @
    filter = 
      "$or" : [
        { status:"unprocessed"}, 
        { status:"retrying" }
      ]
    sort = [["priority", 1]]
    update =
      "$set":
        status: "processing"
        lastModified: Date.now
    
    this.collection.findAndModify(filter,sort, update,(err, job) ->
      if job?._id?
        self.findById(job._id, func)    
      else
        func(null,null)
    )

}  
  
mongoose.model 'Job', schema