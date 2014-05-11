_ = require('lodash')
io = require('socket.io').listen(3000)
require('dotenv').load()

brain = {}

# Handler for socket connections.
io.sockets.on('connection', (socket) ->
  _.each brain, (v,k) ->
    socket.emit(k, v)
)

# Define jobs for resque. the default job is 'data' which passes the argument
# on to all sockets.
resqueJobs =
  sky: (arg,callback) ->
    console.log "sky", arg
    brain.sky = arg
    io.sockets.emit 'sky', arg
    callback()
  lights: (arg,callback) ->
    console.log "lights", arg
    io.sockets.emit "lights", arg
    brain.lights = arg
    callback()
  flash: (arg,callback) ->
    conole.log "flash", arg
    io.sockets.emit "flash", arg
    callback()
  succeed: (arg,callback) -> callback()
  fail: (arg,callback) -> callback(new Error('fail'))

# Set up RedisWorker to attach to the queue named 'empire'.
redisWorker = require('coffee-resque').connect({
  host: "localhost"
  port: 6379
  timeout: 1000
}).worker('empire', resqueJobs)

redisWorker.start()