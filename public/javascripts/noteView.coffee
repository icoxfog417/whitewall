#client side event handler

getScope = -> angular.element($("body")).scope();
updatePostit = (p) -> 
  $scope = getScope()
  index  = Postit.getIndexById($scope.postits,p.id)
  target = $scope.postits[index]
  if target? 
    target.contents = p.contents    
  else
    $scope.postits.push(p)

#socket event handler
GV.socket.on 'connect',()->
  GV.socket.emit('login',GV.identify)

GV.socket.on 'news',(info)->
  $scope = getScope()
  $scope.news = info.news
  $scope.$apply()

GV.socket.on 'init',(receive)->
  $scope = getScope()
  if receive? 
    for p in receive
      updatePostit(p)
    $scope.$apply()

GV.socket.on 'update',(receive)->
  updatePostit(receive)
  getScope().$apply()

GV.socket.on 'delete',(receive)->
  $scope = getScope()
  $scope.closePostit(null,$("#" + receive.id))
  $scope.$apply()
  
GV.socket.on 'move',(receive)->
  $scope = getScope()
  index  = Postit.getIndexById($scope.postits,receive.id)
  p = $scope.postits[index]
  p.position = receive
  $("#" + receive.id).offset({top:receive.top,left:receive.left})
