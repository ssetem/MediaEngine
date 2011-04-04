Job = require './domain/Job'
_ = require('underscore')._
Step = require 'step'
Util = require 'util'

class JobFlowManager
  


  
  processNext:(func) ->
    self = this
    Step(
    
      #get a job from the queue
      ()-> self.popJob this
      
      #check job and porential error
      (err, job)->
        if err then func err
        if job?
          
          if job.type is "parallel" or job.type is "sequential"
            Step(
              ()-> 
                job.status = "waiting_on_dependants"
                job.save this
              
              (err)->
                if err then func err
                
                sel = {parentJobId:job._id}
                if job.type is "sequential" then sel.index = 0
                
                Job.collection.update(
                  sel,
                  { "$set": {status:"ready_for_processing"} },
                  {upsert:false, multi:true},
                  this
                )
              (err)->
                if err then Util.log err; func err
                Util.log "job:#{job._id} started #{job.type} child jobs"
                func()
            )

          else if job.type is "job"
            func null, job
          else
            func null, null
        else
          func null, null
    )
  
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
        func()
    )  

  jobErrored:(errorOptions, job, next)->
    
    cancelRetry = errorOptions?.retry is false
    
    if !cancelRetry and job.retryCount < 3
      job.status = "retrying"
      job.retryCount++
      Util.log "job: #{job._id} errored, attempting retry:#{job.retryCount}"
      job.save next
    else
      job.status ="failed"
      Util.log "job #{job._id} failed"
      job.errorMessage = job.errorMessage || ""
      job.save next



  jobSuccessful:(job, next)->
    self = this
    
    if job.nextJobId?
      Step(
        ()->
          job.status = "completed"
          job.save this
        (err)->
          if err then Util.log err; next err
          Job.findById(job.nextJobId, (err, nextJob)->
            if err then Util.log err; next err
            nextJob.status = "ready_for_processing"
            nextJob.save next()
          )
      )
    
    if job.childJobId?
      
      Step(
        #set status, save the item
        ()->
          job.status = "completed_and_waiting_on_dependants"
          job.save this
          
        (err)->
          if err then Util.log err; next err
          Job.findById(job.childJobId, (err, childJob) ->
            if err then Util.log err; next err
            if childJob?
              childJob.status = "ready_for_processing"
              childJob.save this
            else
              Util.log("somethign went wrong")
              next()
          )
          
        (err)->
          Util.log "job: #{job._id} completed, waiting on child jobs"                    
          next(err)
          
      )
    else   
      job.status = "completed"
      Step(
        ()->job.save this
        (err)->
          if err then Util.log err
          if job.parentJobId?
            #Util.log "job: #{job._id} completed, notifying parents"              
            next()
            self.notifyParents(job)
          else
            Util.log "job: #{job._id} completed"              
            next()
      )
  
  notifyParents:(job)->
    self = this
    
    Job.findById(job.parentJobId, (err, parentJob)->
      if err then Util.log err
      setStatus = ->
        parentJob.status = "completed"
        parentJob.save( (err)->
          if parentJob.parentJobId?
            #Util.log "job: #{job._id} completed, since children completed, notifying grandparents"            
            self.notifyParents(parentJob)
          else
            #Util.log "job: #{job._id} completed, since children completed"
        )
      
      
      if(parentJob.type == "job" && parentJob.childJobId? && job._id.toString() == parentJob.childJobId.toString())
        setStatus()
      else if( parentJob.type =="parallel" or parentJob.type == "sequential" )
        Job.count({parentJobId:parentJob._id}, (err, count)->
          
          if parseInt(parentJob.childCount) == parseInt(count)
            setStatus()        

        )
    )
    
        
    
module.exports = JobFlowManager