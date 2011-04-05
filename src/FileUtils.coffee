util = require "util"
fs = require "fs"
path = require "path"
Step = require 'step'
_ = require("underscore")._

FileUtils = 
  copyFile : (source, dest, callback)->
    
    dirname = path.dirname dest
    
    Step(
      
      #check source directory exists
      ()-> path.exists source, this
      
      #handle non existence
      #make destination directories
      (exists) ->
          unless exists is true
            callback(new Error("Source directory does not exist"))
          else
            FileUtils.mkdirp dirname, 0755,this
      
      #copy the file
      (err) ->
        if err 
          console.log  err
          callback err

        read = fs.createReadStream source
        write = fs.createWriteStream dest

        util.pump read, write, callback
    
    )  
  
  mkdirp:  (p, mode, next )->
      next ?= ()->
      if p.charAt(0) isnt '/' 
        next "Relative path: #{p}"

      ps = path.normalize(p).split('/');
      path.exists p, (exists)->
        if exists 
           return next null
        
        errNotOk = (err)->
          err? and err.code isnt "EEXIST"

        FileUtils.mkdirp ps.slice(0,-1).join("/"), mode, (err)->
          if errNotOk(err) 
             next err
          else
            fs.mkdir p, mode, (err)->
              if errNotOk(err)
                next(err)
              else
                next(null)
          
  readdirFullpath:( folder, next)->
    fs.readdir folder,(err, files)->
      if err then next err
      filesFull = _.map files, (f) -> folder + "/" + f
      next null, filesFull

  
  rmdirSyncRecursive:(p)->
    path.exists p ,(exists)->
      if exists then FileUtils._rmdirSyncRecursive p
      
  _rmdirSyncRecursive : (path)->
    files = fs.readdirSync(path)
    currDir = path
    for f in files
      currentPath = "#{currDir}/#{f}"
      currFile = fs.statSync currentPath
      if currFile.isDirectory()
        FileUtils._rmdirSyncRecursive currentPath
      else 
        fs.unlinkSync currentPath
    fs.rmdirSync path

    

module.exports = FileUtils