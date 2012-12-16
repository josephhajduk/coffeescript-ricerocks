{exec} = require 'child_process'

task "default", "build the files", (options) ->
  exec "/usr/local/bin/node /usr/local/share/npm/bin/coffee --compile --output js/ coffee/*", (a,b,c) ->
    console.log b
    console.log c