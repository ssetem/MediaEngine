testCase = require('nodeunit').testCase
fileUtils = require '../../lib/FileUtils'
path = require 'path'

testcases = 
	setUp: (callback)->
	 @loremFile =  path.normalize(__dirname + "/../resources/lorem.txt")
	 @jpgFile = path.normalize(__dirname + "/../resources/cw081681_9155.jpg")	
	 callback()
	 
	"identifies txt file":(test)->
		test.expect(1)
		fileUtils.identifyFileMimeType this.loremFile, (mime) ->
	    	test.equals mime, "text/plain"
	    	test.done()
	
	"identifies image file":(test)->
		test.expect(1)
		fileUtils.identifyFileMimeType this.jpgFile, (mime) ->
	    	test.equals mime, "image/jpeg"
	    	test.done()
                
	

module.exports = testCase(testcases)