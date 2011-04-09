JobWorker = require './lib/JobWorker'
MediaItem = require './lib/domain/MediaItem'

MediaItem.basePath= __dirname + "/filestore"

jobWorker = new JobWorker({
  mongoURL:"mongodb://localhost/media_engine"
})



  
jobWorker.takeJob()
   
