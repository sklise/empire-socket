port = parseInt process.env['PORT']
_ = require('lodash')
io = require('socket.io').listen(port)
url = require('url')
EventEmitter = require('events').EventEmitter

brain = {}

redisUrl = url.parse(process.env.REDISCLOUD_URL)

messenger = new EventEmitter();

# Handler for socket connections.
io.sockets.on('connection', (socket) ->
  _.each brain, (v,k) ->
    socket.emit(k, v)

  messenger.on 'flash', (data) ->
    console.log "received flash to socket connection"
    socket.emit 'flash', data
)

# Define jobs for resque. the default job is 'data' which passes the argument
# on to all sockets.
resqueJobs =
  sky: (arg, callback) ->
    console.log "sky", arg.details.color
    brain.sky = arg.details.color
    io.sockets.emit 'sky', arg.details.color
    callback()
  lights: (arg, callback) ->
    console.log "lights", arg.details.color
    io.sockets.emit "lights", arg.details.color
    brain.lights = arg.details.color
    callback()
  flashes: (arg, callback) ->
    console.log "flash", arg
    messenger.emit 'flash', arg.details
    callback()

# Set up RedisWorker to attach to the queue named 'empire'.
redisWorker = require('coffee-resque').connect({
  host: redisUrl.hostname
  port: redisUrl.port
  password: redisUrl.auth.split(":")[1]
  timeout: 1000
}).worker('empire', resqueJobs)

redisWorker.on 'error', (err, worker, queue, job) ->
  console.log "ERROR: #{worker}", err

redisWorker.start()