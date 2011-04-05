(function() {
  var ObjectId, Step, aliases, k, mongoose, schema, v;
  var __hasProp = Object.prototype.hasOwnProperty;
  mongoose = require('mongoose');
  Step = require('step');
  ObjectId = mongoose.Schema.ObjectId;
  schema = new mongoose.Schema({
    previousJobId: {
      type: ObjectId
    },
    mediaItemId: {
      type: ObjectId,
      index: true
    },
    parentJobId: {
      type: ObjectId,
      index: true
    },
    nextJobId: ObjectId,
    childJobId: ObjectId,
    name: String,
    jobPath: String,
    processor: String,
    creationDate: {
      type: Date,
      "default": Date.now,
      index: true
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
      "enum": ["ready_for_processing", "processing", "retrying", "completed", "failed", "dependant", "completed_and_waiting_on_dependants", "waiting_on_dependants"],
      "default": "ready_for_processing",
      index: true
    },
    childCount: Number,
    index: Number,
    type: {
      type: String,
      "enum": ["parallel", "sequential", "job"],
      "default": "job"
    },
    parentJobType: {
      type: String,
      "enum": ["parallel", "sequential", "job", "none"],
      "default": "none"
    },
    processor: {
      type: String
    },
    errorMessage: String,
    outputFiles: [String],
    data: {},
    retryCount: {
      type: Number,
      "default": 0
    }
  });
  schema.method({
    isMultiple: function() {
      return this.type === "parallel" || this.type === "sequential";
    },
    saveStatus: function(status, next) {
      this.status = status;
      return this.save(next);
    }
  });
  schema.static({});
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
