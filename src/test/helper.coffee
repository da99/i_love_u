luv = require "i_love_u"
exports.new_luv = (args...) ->
  new luv.i_love_u(args...)
_ = require "underscore"

exports.stack = (env) ->
  env.vars().array('var_values')



