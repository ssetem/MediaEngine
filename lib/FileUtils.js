(function() {
  var FileUtils, Step, fs, mkdirp, path, util;
  util = require("util");
  fs = require("fs");
  path = require("path");
  mkdirp = require('mkdirp').mkdirp;
  Step = require('step');
  FileUtils = {
    copyFile: function(source, dest, callback) {
      var dirname;
      dirname = path.dirname(dest);
      return Step(function() {
        return path.exists(source, this);
      }, function(exists) {
        if (exists !== true) {
          return callback(new Error("Source directory does not exist"));
        } else {
          return mkdirp(dirname, 0755, this);
        }
      }, function(error) {
        var read, write;
        if (error) {
          callback(error);
        }
        read = fs.createReadStream(source);
        write = fs.createWriteStream(dest);
        return util.pump(read, write, callback);
      });
    },
    rmdirSyncRecursive: function(p) {
      return path.exists(p, function(exists) {
        if (exists) {
          return FileUtils._rmdirSyncRecursive(p);
        }
      });
    },
    _rmdirSyncRecursive: function(path) {
      var currDir, currFile, currentPath, f, files, _i, _len;
      files = fs.readdirSync(path);
      currDir = path;
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        f = files[_i];
        currentPath = "" + currDir + "/" + f;
        currFile = fs.statSync(currentPath);
        if (currFile.isDirectory()) {
          FileUtils._rmdirSyncRecursive(currentPath);
        } else {
          fs.unlinkSync(currentPath);
        }
      }
      return fs.rmdirSync(path);
    }
  };
  module.exports = FileUtils;
}).call(this);
