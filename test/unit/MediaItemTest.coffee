require.paths.unshift '../../lib'

testCase = require('nodeunit').testCase
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
MediaItem = require '../../lib/domain/MediaItem'
FileUtils = require '../../lib/FileUtils'

testcases = 
	setUp: (callback)->
    @loremFile =  path.normalize(__dirname + "/../resources/lorem.txt")
    @outputDir = path.normalize(__dirname + "/../output")
    mongoose.connect "mongodb://localhost/test_media_engine"
    callback()
	
	tearDown:(callback) ->
    FileUtils.rmdirSyncRecursive(@outputDir)	  
    MediaItem.collection.remove ->
	    mongoose.disconnect()
	    callback()	  
	  
	"test file exists":(test)->
    test.expect 1
    console.log @loremFile
    path.exists @loremFile, (exists)->
      test.ok(exists)
      test.done()
  
  "test new media item":(test)->
    test.expect(6)
    MediaItem.basePath = @outputDir
    MediaItem.saveFile @loremFile, (err, mediaItem)->
      test.ifError(err)
      test.ok(true)
      test.ok(mediaItem?)
      test.equals mediaItem.filename, "lorem.txt"
      test.equals mediaItem.extension, ".txt"
      path.exists mediaItem.getFilePath(), (exists) ->        
        test.ok(exists)
        test.done() 
   
     
     
    
    

module.exports = testCase(testcases)