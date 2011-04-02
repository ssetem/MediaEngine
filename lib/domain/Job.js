(function() {
  var mongoose, schema;
  mongoose = require('mongoose');
  schema = new mongoose.Schema({
    creationDate: {
      type: Date,
      "default": Date.now
    },
    lastModified: {
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
    errorMessage: String,
    data: {},
    retryCount: {
      type: Number,
      "default": 0
    }
  });
  schema.method({
    complete: function(func) {
      this.status = "completed";
      return this.save(func);
    },
    retry: function(errorMessage, func) {
      this.errorMessage = errorMessage;
      if (this.retryCount < 3) {
        this.status = "retrying";
        this.retryCount++;
      } else {
        this.status = "failed";
      }
      return this.save(func);
    },
    fail: function(errorMessage, func) {
      this.errorMessage = errorMessage;
      this.status = "failed";
      return this.save(func);
    }
  });
  schema.static({
    processNext: function(func) {
      var filter, self, sort, update;
      self = this;
      filter = {
        "$or": [
          {
            status: "unprocessed"
          }, {
            status: "retrying"
          }
        ]
      };
      sort = [["priority", 1]];
      update = {
        "$set": {
          status: "processing",
          lastModified: Date.now
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
