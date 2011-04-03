(function() {
  var ObjectId, aliases, k, mongoose, schema, v;
  var __hasProp = Object.prototype.hasOwnProperty;
  mongoose = require('mongoose');
  ObjectId = mongoose.Schema.ObjectId;
  schema = new mongoose.Schema({
    parentJobId: ObjectId,
    nextJobId: ObjectId,
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
      "enum": ["ready_for_processing", "processing", "retrying", "completed", "failed", "dependant", "completed_and_waiting_on_dependants", "waiting_on_dependents"],
      "default": "ready_for_processing",
      index: true
    },
    childCount: Number,
    jobIndex: Number,
    type: {
      type: String,
      "enum": ["parallel", "sequential", "job"],
      "default": "job"
    },
    parentJobType: {
      type: String,
      "enum": ["parallel", "sequential", "job"],
      "default": null
    },
    processor: {
      type: String
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
      var self;
      self = this;
      this.status = "completed";
      return this.save(func);
    },
    retry: function(errorMessage, func) {
      var self;
      this.errorMessage = errorMessage;
      self = this;
      if (this.retryCount < 3) {
        this.status = "retrying";
        this.retryCount++;
        return this.save(func);
      } else {
        return this.fail.apply(this, arguments);
      }
    },
    fail: function(errorMessage, func) {
      var self;
      this.errorMessage = errorMessage;
      console.log("failed");
      self = this;
      this.status = "failed";
      return this.save(fun);
    }
  });
  schema.static({
    find: function(id, func) {
      return this.collection.findById(id, func);
    },
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
  aliases = {
    "current_job": "Job",
    "completed_job": "CompletedJob",
    "failed_job": "FailedJob"
  };
  for (k in aliases) {
    if (!__hasProp.call(aliases, k)) continue;
    v = aliases[k];
    mongoose.model(k, schema);
    global[v] = mongoose.model(k);
  }
  module.exports = mongoose.model("current_job");
}).call(this);
