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
    filename: String
  });
  schema.method({
    getFilePath: function(foldername) {
      if (foldername == null) {
        foldername = "original";
      }
      return "" + MediaItem.basePath + "/" + this._id + "/" + foldername + "/" + this.filename;
    }
  });
  schema.static({
    saveFile: function(filePath, callback) {
      var extension, filename, mediaItem;
      filename = path.basename(filePath);
      extension = path.extname(filePath);
      mediaItem = new MediaItem({
        filename: filename,
        extension: extension
      });
      return Step(function() {
        return mediaItem.save(this);
      }, function(err) {
        if (err) {
          callback(err);
        }
        return FileUtils.copyFile(filePath, mediaItem.getFilePath("original"), this);
      }, function(err) {
        if (err) {
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
