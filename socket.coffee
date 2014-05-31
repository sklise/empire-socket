port = parseInt process.env['PORT']
_ = require('lodash')
io = require('socket.io').listen(port)
url = require('url')
EventEmitter = require('events').EventEmitter

redisUrl = url.parse(process.env.REDISCLOUD_URL)

messenger = new EventEmitter();

# Handler for socket connections.
io.sockets.on('connection', (socket) ->
  sendToSocket = (data) ->
    socket.emit 'flash', data

  messenger.on 'flash', sendToSocket
  socket.on 'disconnect', -> messenger.removeListener('flash', sendToSocket)
)

# Define jobs for resque.
resqueJobs =
  flashes: (arg, callback) ->
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