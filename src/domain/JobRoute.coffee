Job = require './Job'
_ = require('underscore')._

class Marker

class Par extends Marker
  constructor:(@subjobs)->

class Seq extends Marker
  constructor:(@subjobs)->

class SimpleJob extends Marker
  constructor:(options)->
    for own k, v of options
      @[k] = v


class JobRouteManager 
  constructor:(route)->
    @jobs = []
    @archivedJobs = []
    this.processRoute(null, route)
    
  getJobData : (route)->
    clonedJob = _.extend({},route)
    delete clonedJob.subjobs if clonedJob.subjobs?
    delete clonedJob.subjob if clonedJob.subjob?
    return clonedJob
    
    
  processRoute:(parent, route)->
    if route instanceof Marker
      job = new Job()
      @jobs.push job      
      if parent?
        job.parentId = parent._id
        job.status ="dependant"
        job.parentJobType = parent.type
      else
        job.status ="ready_for_processing"
        
      job.data = this.getJobData(route)
    
      if route instanceof Par
        job.childCount = route.subjobs.length
        job.type = "parallel"
      
        for j in route.subjobs
          this.processRoute(job, j)
          
      if route instanceof Seq
        job.childCount = route.subjobs.length
        job.type = "sequential"
        
        subjobs = []
        
        for j, index in route.subjobs
          subjob = this.processRoute(job, j)
          subjob.index = index
          subjobs.push subjob
        
        for j2, index2 in subjobs
          if index2+1 < subjobs.length
            j2.nextJobId = subjobs[index2+1]._id
                        
      if route instanceof SimpleJob
        job.type="job"
        if route.subjob?
          nextJob = this.processRoute(job, route.subjob)
          if nextJob?
            job.nextJobId = nextJob._id
            
      job
      
  saveJobs:(@callback)->
    this._saveJobs()
  
  _saveJobs:()->
    self = this
    if @jobs.length is 0
      @callback()
    else
      job = @jobs.shift()
      job.save (err)->
        if err then self.callback(err)
        self.archivedJobs.push(job)
        self._saveJobs()

module.exports = 
  Par:(a)-> new Par(a)
  Seq:(a)-> new Seq(a) 
  SimpleJob:(a)-> new SimpleJob(a)
  JobRouteManager:JobRouteManager
  
