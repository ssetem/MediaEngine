require.paths.unshift '../../lib'

testCase = require('nodeunit').testCase
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
MediaItem = require '../../lib/domain/MediaItem'
FileUtils = require '../../lib/FileUtils'
Job = require '../../lib/domain/Job'

{Par, Seq, SimpleJob,JobRouteManager} = require '../../lib/domain/JobRoute'


TEXT_ROUTE = Par([
  SimpleJob({
    processor:"capitalise"
  }),
  SimpleJob({
    processor:"truncate", size:50
    subjob: new SimpleJob({
      processor:"capitalise"
    })
  }),
  SimpleJob({
    processor:"replace"
    regex:/(love)/
    replacement:"lovely"
  }),
  Seq([
    SimpleJob({
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
	setUp: (callback)->
    mongoose.connect "mongodb://localhost/test_media_engine"
    callback()
	
  tearDown:(callback) ->
	  callback()	  

  "test new media item":(test)->
    test.ok(true)
    console.log TEXT_ROUTE
    jobRouteManager = new JobRouteManager(TEXT_ROUTE)
    jobs =  jobRouteManager.jobs
    # console.log jobs

    
    #cache variables
    parJob = jobs[0]    
    capitalise = jobs[1]
    truncate = jobs[2]
    truncate_capitalise = jobs[3]
    replace_job = jobs[4]
    seq_job = jobs[5]
    extract_exif = jobs[6]
    extract_iptc = jobs[7]
    solr_index = jobs[8]

    
    
    #test par
    test.equals(parJob.type, "parallel")  
    test.equals(parJob.parentJobType, null)
    test.equals(parJob.childCount, 4)
    
    #test seq
    test.equals(seq_job.type, "sequential")  
    test.equals(seq_job.childCount, 3)
    
    #test processors
    test.equals(capitalise.data.processor, "capitalise")
    test.equals(truncate.data.processor, "truncate")
    test.equals(truncate_capitalise.data.processor, "capitalise")
    test.equals(replace_job.data.processor, "replace")
    
    test.equals(extract_exif.data.processor, "extract_exif")
    test.equals(extract_iptc.data.processor, "extract_iptc")
    test.equals(solr_index.data.processor, "solr_index")  
    
    #test indexes
    test.equals(extract_exif.index, 0)
    test.equals(extract_iptc.index, 1)
    test.equals(solr_index.index, 2)
    
    #test statuses
    test.equals(parJob.status, "ready_for_processing")
    
    for o in [capitalise, truncate, truncate_capitalise, replace_job, seq_job, extract_exif, extract_iptc, solr_index]
      test.equals(o.status, "dependant")
    
    #test data copy
    for o in [parJob,capitalise, truncate, truncate_capitalise, replace_job, seq_job, extract_exif, extract_iptc, solr_index]
      test.ok(!o.data.subjob?)
      test.ok(!o.subjobs?)
      
    #test next job id
    test.equals(truncate.nextJobId, truncate_capitalise._id)
    test.equals(extract_exif.nextJobId, extract_iptc._id)
    test.equals(extract_iptc.nextJobId, solr_index._id)
    test.equals(solr_index.nextJobId, null)
    
    
    
    
    #test parentId
    test.ok(capitalise.parentId == parJob._id)
    test.ok(truncate.parentId == parJob._id)
    test.ok(truncate_capitalise.parentId == truncate._id)
    test.ok(replace_job.parentId == parJob._id)

    test.ok(capitalise.parentId == parJob._id)
    test.ok(truncate.parentId == parJob._id)
    test.ok(truncate_capitalise.parentId == truncate._id)
    test.ok(replace_job.parentId == parJob._id)
    
    job_length = jobs.length
    
    #test saving of jobs
    jobRouteManager.saveJobs ->
      test.equals(jobRouteManager.archivedJobs.length, job_length)
      test.done()
   
     
     
    
    

module.exports = testCase(testcases)