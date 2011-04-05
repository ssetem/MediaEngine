Job = require './domain/Job'
_ = require('underscore')._
Step = require 'step'
#util = require '#util'
async = require 'async'
class JobFlowManager
  


  
  processNext:(func) ->
    self = this
    
    async.waterfall([
      
      (next) -> self.popJob next
      
      (job) -> 
        if job? 
        
          if job.isMultiple()            
            processMultiple(job)          
        
          else if job.type is "job"
            func null, job        
        else
          func null, null
        
    ])
    
    processMultiple = (job, isNull)->
      if job == null
        return
      async.waterfall([
         
        (next)-> job?.saveStatus "waiting_on_dependants", next
      
        (next) ->
          sel = parentJobId:job._id
          sel.index = 0 if job.type is "sequential"
          #console.log sel
          Job.collection.update(
            sel,
            { "$set": {status:"ready_for_processing"} },
            {upsert:false, multi:true, safe:false},
            next
          )          
      
        () ->
          #console.log arguments
          #util.log "job:#{job._id} started #{job.type} child jobs"
          func(null,null)
      ])
    

  popJob: (func)->
    self = @
    filter = 
      "$or" : [
        { status:"ready_for_processing"}, 
        { status:"retrying" }
      ]
    sort = [["priority", 1]]
    update = { "$set":{status: "processing",lastModified: Date.now} }
    Job.collection.findAndModify(filter,sort, update,(err, job)->
          if job?._id
            Job.findById(job._id, func)
          else
            func(null,null)
    )  

  jobErrored:(errorOptions, job, next)->
    
    cancelRetry = errorOptions?.retry is false
    
    if !cancelRetry and job.retryCount < 3
      job.status = "retrying"
      job.retryCount++
      #util.log "job: #{job._id} errored, attempting retry:#{job.retryCount}"
      job.save next
    else
      job.status ="failed"
      #util.log "job #{job._id} failed"
      job.errorMessage = job.errorMessage || ""
      job.save next



  jobSuccessful:(job, next)->
    self = this
    if job.childJobId? and job.status isnt "completed"
      Step(
        #set status, save the item
        ()->
          job.status = "completed_and_waiting_on_dependants"
          job.save this
          
        (err)->
          if err then #util.log err; next err
          Job.findById(job.childJobId, (err, childJob) ->
            if err then #util.log err; next err
            if childJob?
              childJob.status = "ready_for_processing"
              childJob.save this
            else
              #util.log("somethign went wrong")
              next()
          )
          
        (err)->
          #util.log "job: #{job._id} completed, waiting on child jobs"                    
          next(err)
          
      )
    
    else if job.nextJobId?
      Step(
        ()->
          job.status = "completed"
          job.save this
        (err)->
          if err then #util.log err; next err
          Job.findById(job.nextJobId, (err, nextJob)->
            if err then #util.log err; next err
            if nextJob.status isnt "completed"
              nextJob.status = "ready_for_processing"
              nextJob.save next
          )
      )
    

    else   
      job.status = "completed"
      Step(
        ()->job.save this
        (err)->
          if err then #util.log err
          if job.parentJobId?
            ##util.log "job: #{job._id} completed, notifying parents"  
            next()            
            self.notifyParents(job)
          else
            #util.log "job: #{job._id} completed"              
            next()
      )
  
  notifyParents:(job)->
    self = this

    Job.findById(job.parentJobId, (err, parentJob)->
      if err then #util.log err
      setStatus =->
        parentJob.status = "completed"
        self.jobSuccessful(parentJob, (->))
      
      if(parentJob.type == "job" && parentJob.childJobId? && job._id.toString() == parentJob.childJobId.toString())
        return setStatus()
      else if( parentJob.type =="parallel" or parentJob.type == "sequential" )
        Job.count({parentJobId:parentJob._id, status:"completed"}, (err, count)->
          
          if parseInt(parentJob.childCount) == parseInt(count)
            return setStatus()
        )      
    )
    
        
    
module.exports = JobFlowManager