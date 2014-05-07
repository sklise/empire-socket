_ = require('lodash')
io = require('socket.io').listen(3000)
require('dotenv').load()

nano = require('nano')(process.env.CLOUDANT_URL)
cookie = ''
couch = {}

nano.auth(process.env.CLOUDANT_KEY, process.env.CLOUDANT_PASSWORD, (err, body, headers) ->
  throw(err) if (err)

  if headers and headers['set-cookie']
    console.log headers['set-cookie']
    cookie = _.first(headers['set-cookie'][0].split(";"))

  couch = require('nano')({
    url: process.env.CLOUDANT_URL+"/empire"
    cookie: cookie
  })

  console.log "Connected to Couch"

  data = [{"hey":1},{"hey":2},{"hey":3}]
  console.log(data)
  console.log(JSON.stringify(data))

  couch.bulk(docs:data,{method:"post"},(a,b,c) -> console.log(a,b,c))

  run()
)

run = ->
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
      couch.insert(arg, (a,b,c) -> console.log(a,b,c))
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
  }).worker('empire', resqueJobs)

  redisWorker.on('job', (worker, queue, job) ->
    # console.log "GOT A JOB", worker,queue,job
  )

  redisWorker.start()
