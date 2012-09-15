luv = require "i_love_u"
exports.new_luv = (args...) ->
  new luv.i_love_u(args...)

exports.stack = (env) ->
  arr = ( obj.value() for obj in env.data() when not ( obj.name() in ['List'] ) )
  arr



