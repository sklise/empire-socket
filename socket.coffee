port = parseInt process.env['PORT']
_ = require('lodash')
io = require('socket.io').listen(port)
url = require('url')

brain = {}

redisUrl = url.parse(process.env.REDISCLOUD_URL)

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
    console.log "flash", arg
    io.sockets.emit "flash", arg
    callback()

# Set up RedisWorker to attach to the queue named 'empire'.
redisWorker = require('coffee-resque').connect({
  host: redisUrl.hostname
  port: redisUrl.port
  password: redisUrl.auth.split(":")[1]
  timeout: 1000
}).worker('empire', resqueJobs)

redisWorker.on('job', (worker, queue, job) ->
  # console.log "BALLLLLLLS", worker, queue, job
)

redisWorker.on('error', (err, worker, queue, job) ->
  console.log "ERROR: #{worker}", err
)

redisWorker.start()