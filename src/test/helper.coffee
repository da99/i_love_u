luv = require "i_love_u"
exports.new_luv = (args...) ->
  new luv.i_love_u(args...)

exports.stack = (env) ->
  arr = []
  for v in env.vars() 
    if not (v.value().is_a_procedure?())
      arr.push if v.value().values
        obj.value().values()
      else
        obj.value()
  arr



