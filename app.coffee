
###
  Module dependencies.
###

express = require('express')
routes = require('./routes')
user = require('./routes/user')
http = require('http')
path = require('path')
socketio = require('socket.io')

app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'ejs')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.cookieParser('your secret here'))
app.use(express.session())
app.use(app.router)
app.use(require('stylus').middleware(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'public')))

# development only
if 'development' == app.get('env')
  app.use(express.errorHandler())

app.get('/', routes.index.index)
app.post('/', routes.index.login)

server = http.createServer(app)
io = socketio.listen(server)

# invoke server
server.listen app.get('port'), ->
  console.log('Express server listening on port ' + app.get('port'))

#socket.io process
#http://stackoverflow.com/questions/10058226/send-response-to-all-clients-except-sender-socket-io
room = io.sockets.on('connection',(socket) -> 
  socket.on 'login',(identify)=>
    socket.join(identify.room)
    socket.broadcast.to(identify.room).emit('news',{'news':identify.name + " checkin room. "})
    
  socket.on 'update',(data)=>
    socket.broadcast.to(data.identify.room).emit('update',data)

  socket.on 'delete',(data)=>
    socket.broadcast.to(data.identify.room).emit('delete',data)

  socket.on 'move',(data)=>
    socket.broadcast.to(data.identify.room).emit('move',data)
  
)

