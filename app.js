// Generated by CoffeeScript 1.6.3
/*
  Module dependencies.
*/


(function() {
  var APP, app, express, http, io, path, room, routes, server, socketio, user;

  express = require('express');

  routes = require('./routes');

  user = require('./routes/user');

  http = require('http');

  path = require('path');

  socketio = require('socket.io');

  app = express();

  app.set('port', process.env.PORT || 3000);

  app.set('views', path.join(__dirname, 'views'));

  app.set('view engine', 'ejs');

  app.use(express.favicon(__dirname + '/public/images/favicon.ico'));

  app.use(express.logger('dev'));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(express.cookieParser('your secret here'));

  app.use(express.session());

  app.use(app.router);

  app.use(require('stylus').middleware(path.join(__dirname, 'public')));

  app.use(express["static"](path.join(__dirname, 'public')));

  if ('development' === app.get('env')) {
    app.use(express.errorHandler());
  }

  app.get('/', routes.index.index);

  app.post('/', routes.index.login);

  server = http.createServer(app);

  io = socketio.listen(server);

  server.listen(app.get('port'), function() {
    return console.log('Express server listening on port ' + app.get('port'));
  });

  APP = {};

  APP.PostitsInRoom = [];

  APP.getClientRoom = function(socket) {
    var k, room, rooms, v;
    rooms = io.sockets.manager.roomClients[socket.id];
    room = '';
    for (k in rooms) {
      v = rooms[k];
      if (k.length > 0) {
        room = k.substr(1);
        break;
      }
    }
    return room;
  };

  APP.getIndexOfPostit = function(socket, p) {
    var findout, index, postit, rooms, _i, _len, _ref;
    rooms = APP.getClientRoom(socket);
    index = 0;
    findout = false;
    if (room in APP.PostitsInRoom) {
      _ref = APP.PostitsInRoom[room];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        postit = _ref[_i];
        if (p.id.toString() === postit.id.toString()) {
          findout = true;
          break;
        }
        index++;
      }
    }
    if (findout) {
      return index;
    } else {
      return -1;
    }
  };

  APP.updatePostits = function(socket, p) {
    var index;
    index = APP.getIndexOfPostit(socket, p);
    if (index > -1) {
      return APP.PostitsInRoom[room].splice(index, 1, p);
    } else {
      if (!(room in APP.PostitsInRoom)) {
        APP.PostitsInRoom[room] = [];
      }
      return APP.PostitsInRoom[room].push(p);
    }
  };

  APP.deletePostits = function(socket, p) {
    var index;
    index = APP.getIndexOfPostit(socket, p);
    if (index > -1) {
      return APP.PostitsInRoom[room].splice(index, 1);
    }
  };

  room = io.sockets.on('connection', function(socket) {
    var _this = this;
    socket.on('login', function(identify) {
      socket.join(identify.room);
      socket.broadcast.to(identify.room).emit('news', {
        'news': identify.name + " checkin room. "
      });
      return socket.emit('init', APP.PostitsInRoom[identify.room]);
    });
    socket.on('update', function(p) {
      APP.updatePostits(socket, p);
      return socket.broadcast.to(p.identify.room).emit('update', p);
    });
    socket.on('delete', function(p) {
      APP.deletePostits(socket, p);
      return socket.broadcast.to(room).emit('delete', p);
    });
    socket.on('move', function(pos) {
      var index;
      room = APP.getClientRoom(socket);
      index = APP.getIndexOfPostit(socket, pos);
      if (index > -1) {
        APP.PostitsInRoom[room][index].position = pos;
      }
      return socket.broadcast.to(room).emit('move', pos);
    });
    return socket.on('disconnect', function() {
      var clients;
      room = APP.getClientRoom(socket);
      clients = io.sockets.clients(room);
      console.log(clients.length);
      if (clients.length <= 1) {
        return delete APP.PostitsInRoom[room];
      }
    });
  });

}).call(this);
