util = require "util"
fs = require "fs"
path = require "path"
{mkdirp} = require 'mkdirp'
Step = require 'step'

FileUtils = 
  copyFile : (source, dest, callback)->
    
    dirname = path.dirname dest
    
    Step(
      
      #check source directory exists
      ()-> path.exists source, this
      ,
      #handle non existence
      #make destination directories
      (exists) ->
          unless exists is true
            callback(new Error("Source directory does not exist"))
          else
            mkdirp dirname, 0755,this
      ,
      #copy the file
      (error) ->
        if error then callback error
        read = fs.createReadStream source
        write = fs.createWriteStream dest

        util.pump read, write, callback
    
    )  
  
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