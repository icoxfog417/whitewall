noteApp = angular.module('noteApp',[])

class jqueryPep
  _socket = GV.socket
  pep: (jqobj)->
    _socket = _socket
    jqobj.pep({
        initiate: (ev, obj)->obj.startPosition = obj.$el.offset(),
        drag: (ev, obj, v) -> 
          v = v || obj.velocity()
          $pos = obj.$el.offset();
          pos = new Position(obj.$el.attr("id"),$pos.top,$pos.left)
          idx = Postit.getIndexById(GV.getScope().postits,obj.$el.attr("id"))
          GV.getScope().postits[idx].position = pos
          _socket.emit('move',pos);
        ,
        elementsWithInteraction: false,
        constrainTo: 'parent'
        
    })

noteApp.controller('PostitListCtrl',($scope) ->
  _identify = GV.identify
  _socket = GV.socket
  
  $scope.postits = []
  $scope.identify = _identify
  $scope.news = ""
    
  $scope.escapeContent = (text) ->
    source = (text || '').toString();
    urlArray = [];
    matches ;
    
    #escape text
    source = $("<div>" + source + "</div>").text()
    
    #Regular expression to find FTP, HTTP(S) and email URLs.
    regexToken = /(((ftp|https?):\/\/)[\-\w@:%_\+.~#?,&\/\/=]+)|((mailto:)?[_.\w-]+@([\w][\w\-]+\.)+[a-zA-Z]{2,3})/g;
    
    #Iterate through any URLs in the text.
    while ( matches = regexToken.exec(source) )? 
      token = matches[0]
      urlArray.push(token)

    for url in urlArray
      source = source.replace(url,"<a href='"+url+"' target='_blank' >" + (if url.length <= 30 then url else url.substring(0,27) + "..." ) + "</a>" )

    return source;

  #view event handler
  $scope.addPostit = ()-> 
    diff = $scope.postits.length * 21
    p = new Postit()
    p.identify = _identify
    p.position = { top:110 + diff,left:25 }
    p.contents.push(new Content(ContentType.Document,""))
    $scope.postits.push(p)
  
  $scope.toggleEditing =()->
    jObj = $(event.target)
    area = jObj.closest('.item')
    if area.length > 0
      h = area.height();
      area.addClass('editing')
      editor = area.find("textarea").height(h).focus()
      $.pep.unbind(jObj.closest('.postit'));
    else if !jObj.closest('.editor').length > 0
      jpep = new jqueryPep();
      $('.editing').closest(".postit").each( ->
        idx = Postit.getIndexById($scope.postits,$(this).prop("id"))
        p = $scope.postits[idx]
        jpep.pep($(this))
        _socket.emit('update',p)
      )
      $('.editing').removeClass('editing');
  
  $scope.closePostit = (dom) ->
    target = {};
    event.preventDefault();
    event.stopPropagation();

    if dom? then target = dom else target = $(event.target).closest('.postit');      
    if target?
      idx = Postit.getIndexById($scope.postits,target.prop("id"))
      removed = null
      removed = $scope.postits.splice(idx,1) if idx > -1
      if removed?
        _socket.emit('delete',removed[0])
    
)

noteApp.directive('postitRender', -> 
  (scope, element, attrs) ->
    jpep = new jqueryPep();
    jqElem = angular.element(element)    
    jqElem.offset({top:scope.p.position.top,left:scope.p.position.left})
    jpep.pep(jqElem);
    Hammer(element[0]).on("hold",->
      scope.toggleEditing()
    )
    Hammer(jqElem.find(".post-close").get(0)).on("tap",->
      scope.closePostit()
    )

)
