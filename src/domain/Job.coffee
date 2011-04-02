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
    self = @
    this.status = "completed"
    new CompletedJob(this.toJSON()).save ->
      self.remove func
  
  retry:(@errorMessage,func) ->
    self = @
    if this.retryCount < 3
      this.status = "retrying"
      this.retryCount++
      this.save func
    else
      this.fail.apply(this, arguments)

  
  fail: (@errorMessage,func) ->
    console.log "failed"
    self = @
    this.status = "failed"
    new FailedJob(this.toJSON()).save ->
      self.remove func
}
  
schema.static {
	
  find:(id, func) ->
	this.collection.findById(id, func);
  
    
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

aliases = 
  "current_job" : "Job"
  "completed_job" : "CompletedJob"
  "failed_job" : "FailedJob"

for own k,v of aliases
  mongoose.model k, schema
  global[v] = mongoose.model k
