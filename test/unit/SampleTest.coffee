testCase = require('nodeunit').testCase;

testcases = 
	setUp: (callback)->
	 @somevar = true
	 callback()
	 
	"test instance boolean":(test)->
	    test.expect(1)
	    test.equals(@somevar, true)
	    test.done()

module.exports = testCase(testcases)