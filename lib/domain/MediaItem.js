(function() {
  var FileUtils, MediaItem, Step, mongoose, path, schema;
  mongoose = require('mongoose');
  path = require('path');
  FileUtils = require('../FileUtils');
  Step = require('step');
  schema = new mongoose.Schema({
    creationDate: {
      type: Date,
      "default": Date.now
    },
    lastModified: {
      type: Date,
      "default": Date.now
    },
    extension: String,
    filename: String,
    generatedFiles: {}
  });
  schema.method({
    setGenerateOutputFiles: function(jobPath, files, next) {
      var update;
      update = {};
      update["generatedFiles." + jobPath] = {
        status: "completed",
        paths: files
      };
      return this.collection.update({
        _id: this._id
      }, {
        "$set": update
      }, {}, next);
    },
    getRelativeFilePath: function() {
      return "" + (this.getRelativeFolderPath()) + "/original/output" + this.extension;
    },
    getRelativeFolderPath: function() {
      return "/" + this._id;
    },
    getFilePath: function() {
      return "" + (this.getFolderPath()) + "/original/output" + this.extension;
    },
    getFolderPath: function() {
      return "" + MediaItem.basePath + "/" + this._id;
    }
  });
  schema.static({
    saveFile: function(filePath, callback) {
      var extension, filename, mediaItem;
      filename = path.basename(filePath).replace(/\.\w+$/, "");
      extension = path.extname(filePath);
      mediaItem = new MediaItem({
        filename: filename,
        extension: extension
      });
      mediaItem.generatedFiles = {
        "/original/": {
          status: "completed",
          paths: [mediaItem.getRelativeFilePath()]
        }
      };
      return Step(function() {
        return mediaItem.save(this);
      }, function(err) {
        if (err) {
          console.log(err);
          callback(err);
        }
        return FileUtils.copyFile(filePath, mediaItem.getFilePath("original"), this);
      }, function(err) {
        if (err) {
          console.log(err);
          return mediaItem.remove(function() {
            return callback(err);
          });
        } else {
          return callback(null, mediaItem);
        }
      });
    }
  });
  mongoose.model('MediaItem', schema);
  module.exports = MediaItem = mongoose.model('MediaItem');
}).call(this);
