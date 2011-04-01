(function() {
  var mongoose, schema;
  mongoose = require('mongoose');
  schema = new mongoose.Schema({
    creationDate: {
      type: Date,
      "default": Date.now
    },
    priority: {
      type: Number,
      "default": 5,
      index: true
    },
    status: {
      type: String,
      "enum": ["unprocessed", "processing", "retrying", "completed", "failed"],
      "default": "unprocessed",
      index: true
    },
    retryCount: {
      type: Number,
      "default": 0
    }
  });
  schema.method({
    setStatus: function(status, func) {
      this.status = status;
      return this.save(func);
    }
  });
  schema.static({
    pop: function(func) {
      var filter, self, sort, update;
      self = this;
      filter = {
        status: "unprocessed"
      };
      sort = [["priority", 1]];
      update = {
        "$set": {
          status: "processing"
        }
      };
      return this.collection.findAndModify(filter, sort, update, function(err, job) {
        if ((job != null ? job._id : void 0) != null) {
          return self.findById(job._id, func);
        } else {
          return func(null, null);
        }
      });
    }
  });
  mongoose.model('Job', schema);
}).call(this);
