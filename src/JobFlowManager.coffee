Job   = require './domain/Job'
_     = require('underscore')._
Step  = require 'step'
util  = require 'util'
async = require 'async'


class JobFlowManager
  
  
    
  processNext:(func) ->    
    self = this
    errorFunction = this.createErrorFunction func
    async.waterfall([      
        (next)-> self.popJob next      
        (job) -> 
          if job?     
            if job.isMultiple()
              processMultiple(job)          
            else if job.type is "job"
              func null, job        
          else
            func null, null      
      ]
      errorFunction
    )
    
    processMultiple = (job, isNull)->
      if job == null then return
      async.waterfall([         
          (next)-> job.saveStatus "waiting_on_dependants", next      
          (next)->
            query = parentJobId:job._id
            query.index = 0 if job.type is "sequential"
            Job.collection.update(
              query,
              { "$set": {status:"ready_for_processing"} },
              {upsert:false, multi:true, safe:false},
              next
            )                
          () -> func null,null
        ]
        errorFunction
      )
    
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
    

  jobErrored:(errorOptions, job, next)->
    
    cancelRetry = errorOptions?.retry is false
    
    if !cancelRetry and job.retryCount < 3
      job.status = "retrying"
      job.retryCount++
      util.log "job: #{job._id} #{job.jobPath} errored, attempting retry:#{job.retryCount}"
      util.log errorOptions.errorMessage || ""      
      job.save next
    else
      job.status ="failed"
      util.log "job #{job._id} #{job.jobPath} failed"
      util.log errorOptions.errorMessage || ""
      job.errorMessage = job.errorMessage || ""
      job.save next



  jobSuccessful:(job, callback)->
    self = this
    errorFunction = this.createErrorFunction callback
    if job.childJobId? and job.status isnt "completed"
      async.waterfall([
          (next)-> job.saveStatus "completed_and_waiting_on_dependants", next
          (next)->
            Job.findById job.childJobId, (err, childJob) ->
              if childJob?
                childJob.saveStatus "ready_for_processing", next
              else
                util.log("somethign went wrong")
                next new Error("should have child id")
          ()-> callback(null)
        ]
        errorFunction        
      )
    
    else if job.nextJobId?
      async.waterfall([
          (next)-> job.saveStatus "completed", next
          (next)->
            Job.findById job.nextJobId, (err, nextJob)->
              errorFunction err
              if nextJob.status isnt "completed"
                 nextJob.saveStatus "ready_for_processing", next
          ()-> callback null
        ]
        errorFunction
      )
    
    else   
      async.waterfall([
          (next)-> job.saveStatus "completed", next
          ()->
            util.log "job: #{job._id} completed #{job.jobPath}" if job.type is "job"
            self.notifyParents(job) if job.parentJobId?   
            callback null                          
        ]
        errorFunction
      )

  
  notifyParents:(job)->
    Job.findById job.parentJobId, (err, parentJob) =>
      if err then util.log err
      setStatus = =>
        parentJob.status = "completed"
        this.jobSuccessful(parentJob, (->))
      
      if(parentJob.type == "job" && parentJob.childJobId? && job._id.toString() == parentJob.childJobId.toString())
        setStatus()
      else if( parentJob.isMultiple() )
        Job.count {parentJobId:parentJob._id, status:"completed"}, (err, count)->          
          if parseInt(parentJob.childCount) == parseInt(count)
            setStatus()
        
    
    
  createErrorFunction:(callback)->
    (err)-> if err? then util.log err; callback err
    
        
    
module.exports = JobFlowManager