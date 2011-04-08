mongoose  = require 'mongoose'
Step      = require 'step'
ObjectId  = mongoose.Schema.ObjectId

schema = new mongoose.Schema {
  
  previousJobId:
    type:ObjectId
  
  mediaItemId:
    type:ObjectId
    index:true
  
  parentJobId:
    type:ObjectId
    index:true
  
  nextJobId:ObjectId
  
  childJobId:ObjectId
  
  name:String
  
  jobPath:String
  
  processor:String
  
  creationDate: 
    type: Date
    default: Date.now
    index:true
  
  lastModified:
    type: Date
    default: Date.now
  
  priority:
    type: Number
    default: 5
    index:true
    
  status:
    type: String,
    enum: ["ready_for_processing", "processing", "retrying", "completed", "failed", "dependant", "completed_and_waiting_on_dependants", "waiting_on_dependants"]
    default: "ready_for_processing"
    index:true
  
  childCount:Number
  
  index:Number
  
  type:
    type:String
    enum: ["parallel", "sequential", "job"]
    default: "job"


  parentJobType:
    type:String
    enum: ["parallel", "sequential", "job", "none"]
    default : "none"
    
  processor:
    type:String
    
  errorMessage:String
  
  outputFiles:[String]
  #accepts any object
  data:{}
  
  retryCount:
    type:Number
    default:0
}

schema.method {
  
  isMultiple:()->
    @type is "parallel" or @type is "sequential"
  
  saveStatus:(@status, next)->
    this.save next
    
  startChildren:(callback)->
    this.saveStatus "waiting_on_dependants", (err)=>
      if err then callback err
      query = parentJobId:this._id
      query.index = 0 if this.type is "sequential"
      Job.collection.update(
        query,
        { "$set": {status:"ready_for_processing"} },
        {upsert:false, multi:true, safe:false},
        callback
      )      

}


schema.static {

  popJob: (func)->
    filter = 
      "$or" : [
        { status:"ready_for_processing" }
        { status:"retrying" }
      ]
    sort = [["priority", 1]]
    update = { "$set":{status: "processing",lastModified: Date.now} }
    Job.collection.findAndModify filter,sort, update,(err, job)->
      if job?._id
        Job.findById(job._id, func)
      else
        func(null,null)
        
}  

aliases = 
  "current_job" : "Job"
  "completed_job" : "CompletedJob"
  "failed_job" : "FailedJob"

for own k,v of aliases
  mongoose.model k, schema
  global[v] = mongoose.model k

module.exports = mongoose.model "current_job"
