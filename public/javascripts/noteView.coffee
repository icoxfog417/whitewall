#client side event handler

getScope = -> angular.element($("body")).scope();

#socket event handler
GV.socket.on 'connect',()->
  GV.socket.emit('login',GV.identify)

GV.socket.on 'news',(info)->
  $scope = getScope()
  $scope.news = info.news
  $scope.$apply()

GV.socket.on 'update',(receive)->
  #if receive.identify.name != _identify.name
  $scope = getScope()
  target = $scope.find($("#" + receive.id))
  if target? 
    target.contents = receive.contents    
  else
    $scope.postits.push(receive)
  $scope.$apply()

GV.socket.on 'delete',(receive)->
  $scope = getScope()
  $scope.closePostit($("#" + receive.id))
  $scope.$apply()
  
GV.socket.on 'move',(receive)->
  $("#" + receive.id).offset({top:receive.top,left:receive.left})
