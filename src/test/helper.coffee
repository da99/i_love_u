luv = require "i_love_u"
exports.new_luv = (args...) ->
  new luv.i_love_u(args...)

exports.stack = (env) ->
  arr = []
  for obj in env.data() 
    if not (obj.name() in ['List'])
      arr.push if obj.value().values
        obj.value().values()
      else
        obj.value()
  arr



