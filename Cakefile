{exec} = require "child_process"
util   = require "util"


commands = [
  "coffee -c -w -o lib/ src/"
  "coffee -c -w JWServer.coffee"
  "coffee -c -w JMServer.coffee"  
]

for c in commands
  child = exec c
  child.stdout.on "data", util.print
