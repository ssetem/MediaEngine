{exec} = require "child_process"
util   = require "util"


task "watch", "watch coffee files", ->

  commands = [
    "coffee -c -w -o lib/ src/"
    "coffee -c -w JWServer.coffee"
    "coffee -c -w JMServer.coffee"  
    "coffee -c -w server.coffee"
  ]

  for c in commands
    child = exec c
    child.stdout.on "data", util.print
    
execute =(command)->
  return ()->
    e = exec command
    e.stdout.on "data", util.print
    e.stderr.on "data", util.print

task "jws", "autoreload JWServer.js",->
  (exec "nodemon JWServer.js").stdout.on "data", util.print

task "jms", "autoreload JMServer.js",->
  (exec "nodemon JMServer.js").stdout.on "data", util.print

task "server", "autoreload server.js", execute "nodemon server.js"