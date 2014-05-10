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
  data: (arg,callback) ->
    io.sockets.emit 'news', arg
    console.log arguments
    callback()
  succeed: (arg, callback) ->
    console.log 'succeeed'
    callback()
  fail: (arg, callback) ->
    console.log 'fail'
    callback(new Error('fail'))

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
