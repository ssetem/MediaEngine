mongoose = require 'mongoose'


ObjectId = mongoose.Schema.ObjectId

schema = new mongoose.Schema {
  
  parentJobId:ObjectId
  
  nextJobId:ObjectId
  
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
    enum: ["ready_for_processing", "processing", "retrying", "completed", "failed", "dependant", "completed_and_waiting_on_dependants", "waiting_on_dependents"]
    default: "ready_for_processing"
    index:true
  
  childCount:Number
  
  jobIndex:Number
  
  type:
    type:String
    enum: ["parallel", "sequential", "job"]
    default: "job"


  parentJobType:
    type:String
    enum: ["parallel", "sequential", "job"]
    default : null
    
  processor:
    type:String
    
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
    # new CompletedJob(this.toJSON()).save ->
    #   self.remove func
    this.save func
  
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
    this.save fun
    # new FailedJob(this.toJSON()).save ->
    #   self.remove func
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

module.exports = mongoose.model "current_job"
