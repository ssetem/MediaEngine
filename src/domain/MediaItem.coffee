mongoose = require 'mongoose'
path = require 'path'
FileUtils = require('../FileUtils')
Step = require 'step'

schema = new mongoose.Schema {
  
  creationDate: 
    type: Date
    default: Date.now
  
  lastModified:
    type: Date
    default: Date.now
  
  extension:String
  
  filename:String

}

schema.method {
  
  
  getFilePath:()->
     "#{@getFolderPath()}/original/output#{@extension}"
  
  getFolderPath:->
    "#{MediaItem.basePath}/#{this._id}"
  
}

schema.static {
  
  
  saveFile:(filePath, callback) ->
    
    filename = path.basename(filePath).replace(/\.\w+$/,"")
    extension = path.extname(filePath)
    mediaItem = new MediaItem({
      filename:filename 
      extension:extension    
    })
    
    Step(
      # Save the media item
      ()-> mediaItem.save(this)
      ,
      # copy the file to destination directory
      (err)->
        callback err if err
        FileUtils.copyFile filePath, mediaItem.getFilePath("original"), this
      ,  
      # if there is an error rollback
      (err)->
        if err
          mediaItem.remove ->
            callback err
        else
          callback(null, mediaItem)
    )

  
}



mongoose.model 'MediaItem', schema
module.exports = MediaItem = mongoose.model 'MediaItem'