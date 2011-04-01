(function() {
  var mongoose, schema;
  mongoose = require('mongoose');
  schema = new mongoose.Schema({
    creationDate: {
      type: Date,
      "default": Date.now
    },
    priority: {
      type: Integer,
      "default": 5
    }
  });
  mongoose.model('Job', schema);
}).call(this);
