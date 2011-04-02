(function() {
  var testCase, testcases;
  testCase = require('nodeunit').testCase;
  testcases = {
    setUp: function(callback) {
      this.somevar = true;
      return callback();
    },
    "test instance boolean": function(test) {
      test.expect(1);
      test.equals(this.somevar, true);
      return test.done();
    }
  };
  module.exports = testCase(testcases);
}).call(this);
