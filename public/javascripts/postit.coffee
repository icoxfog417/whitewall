class @Position
  constructor:(id,top,left)->
    @id = id
    @top = top
    @left = left
  
class @Postit
  constructor:() ->
    @id = new Date().getTime() #make unique id
    @position = new Position(@id,0,0)
    @identify = {}
    @contents = []
    @isDelete = false

  @getIndexById = (postits,id) -> 
    index = 0
    findout = false
    for p in postits
      if id.toString() == p.id.toString() then findout = true; break;
      index++
    return if findout then index else -1
      
  getIndex : (postits) -> 
    return Postit.getIndexById(postits,@id)
      
  toSend : (method,sender) ->
    p = new Postit(sender.id)
    switch method
      when MethodType.Move
        p.position = sender.position
      when MethodType.Save 
        p.position = sender.position
        p.contents = sender.contents
      when MethodType.Delete 
        p.isDelete = true
    return p

class @MethodType
  constructor:(@index) ->
  @Move = 0
  @Save = 1
  @Delete = 2
  valueOf:() -> @index

class @ContentType
  constructor:(@index) ->
  @Document = 0
  @Link = 1
  @Image = 2
  valueOf:() -> @index
  
class @Content
  constructor:(@type,@value)->
