testCase = require('nodeunit').testCase
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
JobManager = require '../../lib/JobManager'
JobFlowManager = require '../../lib/JobFlowManager'
Job = require "../../lib/domain/Job"
{Par, Seq, SimpleJob,JobRouteManager} = require '../../lib/JobRouteManager'
Step = require 'step'



TEXT_ROUTE = Par([
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
        self.refreshJobs ()->
          callback(err, job)
    
    Job.collection.remove ->
      self.jobRouteManager.saveJobs ->
        self.refreshJobs ()-> callback()
      
    @jobFlowManager = new JobFlowManager()
	
  tearDown:(callback) ->
    #Job.collection.remove ->
    callback()
  
  "test dummy":(test)->
    # self = this
    # # test.equals(self.parJob?.status, "ready_for_processing")
    # self.processNext ()->
    #   # console.log self.truncate?.status
    #   # test.equals(self.parJob?.status, "waiting_on_dependants")
    #   # test.equals(self.capitalise?.status, "ready_for_processing")
    #   # test.equals(self.truncate?.status, "ready_for_processing")
    #   # test.equals(self.replace_job?.status, "ready_for_processing")
    #   
    #   self.processNext (err, job2)->
    #     
    #     # test.equals( job2.status, "processing")
    #     self.jobFlowManager.jobSuccessful job2, ->
    #       
    #       self.processNext (err, job3)->
    #         console.log job3
    #         self.jobFlowManager.jobSuccessful job3, ->
    #         # 
    #         #              self.processNext (err, job)->
    #         #                console.log arguments
    #         #                test.done()
      



module.exports = testCase(testcases)