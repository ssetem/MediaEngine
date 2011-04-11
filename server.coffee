express       = require 'express'
MediaItem     = require "./lib/domain/MediaItem"
mongoose      = require "mongoose"

mongoose.connect "mongodb://localhost/media_engine"

app = module.exports = express.createServer()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')
  app.use express.static(__dirname + '/filestore')


app.configure 'development', ->
  app.use express.errorHandler( dumpExceptions: true, showStack: true )


app.configure 'production', ->
  app.use express.errorHandler()

app.get '/', (req, res) -> res.redirect '/mediaitems'

app.get '/mediaitems', (req, res) ->
  MediaItem.find (err, mediaItems) ->  
    console.log mediaItems
    res.render 'mediaItems/index',
      locals: 
        title: "Media Items"
        mediaItems:mediaItems
  

app.get '/mediaitems/:id', (req, res)->
  MediaItem.findById req.params.id, (err, mediaItem)->
    console.log req.params.id
    res.render 'mediaItems/show',
      locals:
        title: mediaItem.filename
        mediaItem:mediaItem

if(!module.parent)
  app.listen 3000
  console.log "Express server listening on port %d", app.address().port

