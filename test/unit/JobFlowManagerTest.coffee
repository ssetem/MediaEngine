testCase = require('nodeunit').testCase
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
JobManager = require '../../lib/JobManager'
JobFlowManager = require '../../lib/JobFlowManager'
Job = require "../../lib/domain/Job"
{Par, Seq, SimpleJob,JobRouteManager} = require '../../lib/JobRouteManager'
Step = require 'step'



TEXT_ROUTE = Seq([
  SimpleJob({
    name:"capitalise_name"
    processor:"capitalise"
  }),
  SimpleJob({
    name:"truncate_name", processor:"truncate", size:50
    subjob: new SimpleJob({
      processor:"capitalise"
    })
  }),
  SimpleJob({
    name:"replace_name"
    processor:"replace"
    regex:/(love)/
    replacement:"lovely"
  }),
  Seq([
    SimpleJob({
      name:"extract_exif_name"
      processor:"extract_exif"      
    }),
    SimpleJob({
      processor:"extract_iptc"      
    }),
    SimpleJob({
      processor:"solr_index"      
    })
  ])
])

testcases = 
  
  setUp:(callback) ->
    
    self = this
    mongoose.connect "mongodb://localhost/test_media_engine"
    @jobRouteManager = new JobRouteManager(TEXT_ROUTE)
    
    this.refreshJobs =(callback) ->
      Job.find({}, (err, results)->
        [self.parJob, self.capitalise, self.truncate, self.truncate_capitalise,self.replace_job, 
        self.seq_job, self.extract_exif, self.extract_iptc, self.solr_index] = results    
        callback()
      )
      
    self.processNext = (callback)->
      self.jobFlowManager.processNext (err, job)->
        callback(err, job)
    
    Job.collection.remove ->
      self.jobRouteManager.saveJobs ->
        self.refreshJobs ()-> callback()
      
    @jobFlowManager = new JobFlowManager()
	
  tearDown:(callback) ->
    #Job.collection.remove ->
    callback()

  
  "test dummy":(test)->
    self = this
    
    testIds = [self.capitalise._id, self.truncate._id, self.truncate_capitalise._id, self.replace_job._id, self.extract_exif._id, self.extract_iptc._id, self.solr_index._id]
    ids = []
    
    #test.equals(self.parJob?.status, "ready_for_processing")
    
    finish = ->
      test.done()
    
    
    run = ->
      
      self.processNext (err, job)->
               
        if job?
          ids.push(job._id)
          self.jobFlowManager.jobSuccessful( job, ->
            run()
          )
        else
          if ids.length < 7
            setTimeout(run, 10)
              
          else
            setTimeout(finish, 10)
            console.log ids
            test.deepEqual(ids, testIds)
            test.done()

        
    run()
    



module.exports = testCase(testcases)