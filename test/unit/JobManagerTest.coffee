testCase = require('nodeunit').testCase
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
JobManager = require '../../lib/JobManager'

testcases = 
	setUp: (callback)->
    @jobManager = new JobManager({
      mongoURL:"mongodb://localhost/test_media_engine"
    })
    callback()
	
  tearDown:(callback) ->
    Job.collection.remove ->
      callback()    	  
	  
	"test job manager exists":(test)->
    test.expect 1
    test.ok(JobManager?)
    test.done()

  "test add job":(test)->
    test.expect(5)
    job = @jobManager.addJob({
      x:1,y:10
    },{
      priority:3
    })
    job.save (err)->
      test.ifError(err)
      test.ok(job._id?)
      test.equals(job.status, "unprocessed")
      test.deepEqual({x:1, y:10},job.data)
      test.equals(job.priority, 3)
      test.done()
  
  "test find job":(test)->
    test.expect(3)
    j = @jobManager.addJob({message:"hello"})
    j.save (err)=>
      test.ifError(err)
      id = j._id
      @jobManager.getJob id, (err,job)->
        test.ifError(err)
        test.deepEqual(job.data, {message:"hello"})
        test.done()
     
     
    
    

module.exports = testCase(testcases)