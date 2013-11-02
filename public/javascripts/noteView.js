// Generated by CoffeeScript 1.6.3
(function() {
  var getScope, updatePostit;

  getScope = function() {
    return angular.element($("body")).scope();
  };

  updatePostit = function(p) {
    var $scope, index, target;
    $scope = getScope();
    index = Postit.getIndexById($scope.postits, p.id);
    target = $scope.postits[index];
    if (target != null) {
      return target.contents = p.contents;
    } else {
      return $scope.postits.push(p);
    }
  };

  GV.socket.on('connect', function() {
    return GV.socket.emit('login', GV.identify);
  });

  GV.socket.on('news', function(info) {
    var $scope;
    $scope = getScope();
    $scope.news = info.news;
    return $scope.$apply();
  });

  GV.socket.on('init', function(receive) {
    var $scope, p, _i, _len;
    $scope = getScope();
    if (receive != null) {
      for (_i = 0, _len = receive.length; _i < _len; _i++) {
        p = receive[_i];
        updatePostit(p);
      }
      return $scope.$apply();
    }
  });

  GV.socket.on('update', function(receive) {
    updatePostit(receive);
    return getScope().$apply();
  });

  GV.socket.on('delete', function(receive) {
    var $scope;
    $scope = getScope();
    $scope.closePostit($("#" + receive.id));
    return $scope.$apply();
  });

  GV.socket.on('move', function(receive) {
    return $("#" + receive.id).offset({
      top: receive.top,
      left: receive.left
    });
  });

}).call(this);
