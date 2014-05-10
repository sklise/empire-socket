_ = require('lodash')
io = require('socket.io').listen(3000)
require('dotenv').load()

# Handler for socket connections.
io.sockets.on('connection', (socket) ->
  socket.emit('news', {'message':'hey man'})
)

# Define jobs for resque. the default job is 'data' which passes the argument
# on to all sockets.
resqueJobs =
  sky: (arg,callback) ->
    console.log "sky", arg, callback
    io.sockets.emit 'sky', arg
    callback()
  lights: (arg) ->
    console.log "lights", arg, callback
    io.sockets.emit "lights", arg
    callback()
  flash: (arg) ->
    conole.log "flash", arg
    io.sockets.emit "flash", arg

# Set up RedisWorker to attach to the queue named 'empire'.
redisWorker = require('coffee-resque').connect({
  host: "localhost"
  port: 6379
  timeout: 1000
}).worker('empire', resqueJobs)

redisWorker.on('job', (worker, queue, job) ->
  # console.log "GOT A JOB", worker,queue,job
)

redisWorker.start()
