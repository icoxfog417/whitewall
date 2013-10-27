###
  GET home page.
###

exports.index = {}
exports.index.index = (req, res) ->
  res.render('index', {room:''})

exports.index.login = (req,res) ->
  room = req.body.room
  name = req.body.name
  if (room? and room != "") and (name? and name != "")
    identify = JSON.stringify({room:room , name:name})
    res.render('space',{identify:identify})
  else
    res.render('index', {room:room,msg:'IDと名前(ローマ字)を入力します'})
