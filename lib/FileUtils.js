(function() {
  var FileUtils, Step, fs, path, util, _;
  util = require("util");
  fs = require("fs");
  path = require("path");
  Step = require('step');
  _ = require("underscore")._;
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
          return FileUtils.mkdirp(dirname, 0755, this);
        }
      }, function(err) {
        var read, write;
        if (err) {
          console.log(err);
          callback(err);
        }
        read = fs.createReadStream(source);
        write = fs.createWriteStream(dest);
        return util.pump(read, write, callback);
      });
    },
    mkdirp: function(p, mode, next) {
      var ps;
      next != null ? next : next = function() {};
      if (p.charAt(0) !== '/') {
        next("Relative path: " + p);
      }
      ps = path.normalize(p).split('/');
      return path.exists(p, function(exists) {
        var errNotOk;
        if (exists) {
          return next(null);
        }
        errNotOk = function(err) {
          return (err != null) && err.code !== "EEXIST";
        };
        return FileUtils.mkdirp(ps.slice(0, -1).join("/"), mode, function(err) {
          if (errNotOk(err)) {
            return next(err);
          } else {
            return fs.mkdir(p, mode, function(err) {
              if (errNotOk(err)) {
                return next(err);
              } else {
                return next(null);
              }
            });
          }
        });
      });
    },
    readdirFullpath: function(folder, next) {
      return fs.readdir(folder, function(err, files) {
        var filesFull;
        if (err) {
          next(err);
        }
        filesFull = _.map(files, function(f) {
          return folder + "/" + f;
        });
        return next(null, filesFull);
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
