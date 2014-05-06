_ = require('lodash')

io = require('socket.io').listen(3000)

io.sockets.on('connection', (socket) ->
  socket.emit('news', {'message':'hey man'})
)


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

redisWorker = require('coffee-resque').connect({
  host: "localhost"
  port: 6379
}).worker('empire', resqueJobs)

redisWorker.on('job', (worker, queue, job) ->
  # console.log "GOT A JOB", worker,queue,job
)

redisWorker.start()