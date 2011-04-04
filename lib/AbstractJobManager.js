(function() {
  var AbstractJobManager, events, mongoose, utils;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  require.paths.unshift(__dirname + '/node_modules');
  mongoose = require('mongoose');
  utils = require('util');
  require('./domain/Job');
  events = require('events');
  AbstractJobManager = (function() {
    __extends(AbstractJobManager, events.EventEmitter);
    function AbstractJobManager(options) {
      this.options = options;
      AbstractJobManager.__super__.constructor.call(this);
      this.initMongo();
    }
    AbstractJobManager.prototype.initMongo = function() {
      this.db = mongoose.connect(this.options.mongoURL);
      return global.Job = mongoose.model('current_job');
    };
    return AbstractJobManager;
  })();
  module.exports = AbstractJobManager;
}).call(this);
