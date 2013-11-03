
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
app.use(express.favicon(__dirname + '/public/images/favicon.ico'));
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

#global function
APP = {}
APP.PostitsInRoom = []
  
APP.getClientRoom = (socket) ->
  rooms = io.sockets.manager.roomClients[socket.id]
  room = ''
  for k ,v of rooms
    if k.length > 0 then room = k.substr(1); break;  
  return room

APP.getIndexOfPostit = (socket,p) ->
  rooms = APP.getClientRoom(socket)
  index = 0
  findout = false
  if room of APP.PostitsInRoom
    for postit in APP.PostitsInRoom[room]
      if p.id.toString() == postit.id.toString() then findout = true; break;
      index++
  if findout then return index; else return -1;
  
APP.updatePostits = (socket,p) ->
  index = APP.getIndexOfPostit(socket,p)
  if index > -1
    APP.PostitsInRoom[room].splice(index,1,p)
  else
    if !(room of APP.PostitsInRoom) then APP.PostitsInRoom[room] = [];
    APP.PostitsInRoom[room].push(p)  

APP.deletePostits = (socket,p) ->
  index = APP.getIndexOfPostit(socket,p)
  if index > -1 then APP.PostitsInRoom[room].splice(index,1)

room = io.sockets.on('connection',(socket) -> 
  socket.on 'login',(identify)=>
    socket.join(identify.room)
    socket.broadcast.to(identify.room).emit('news',{'news':identify.name + " checkin room. "})
    socket.emit('init',APP.PostitsInRoom[identify.room])
    
  socket.on 'update',(p)=>
    APP.updatePostits(socket,p)
    socket.broadcast.to(p.identify.room).emit('update',p)

  socket.on 'delete',(p)=>
    APP.deletePostits(socket,p)
    socket.broadcast.to(room).emit('delete',p)

  socket.on 'move',(pos)=>
    room = APP.getClientRoom(socket)
    index = APP.getIndexOfPostit(socket,pos)    
    if index > -1
      APP.PostitsInRoom[room][index].position = pos
    socket.broadcast.to(room).emit('move',pos)

  socket.on 'disconnect', =>
    room = APP.getClientRoom(socket)
    clients = io.sockets.clients(room)
    # if client is last client, then delete all postits in room.
    console.log(clients.length)
    if clients.length <= 1 then delete APP.PostitsInRoom[room]
      
)

