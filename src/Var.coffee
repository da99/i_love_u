
rw = require "rw_ize"
_  = require "underscore"

class Var

  rw.ize this
  @read_able "name", "value"
  @read_write_able "is_local_only"
  

  constructor: (name, val, yield_to) ->
    @rw "name",           name
    @rw "value",          val
    @rw "is_local_only",  false
    yield_to(this) if yield_to

  has_regexp_name: () ->
    _.isRegExp(@name())

  is_a_var: () ->
    true

  is_user_defined: () ->
    (not @value().is_a_procedure?()) and (not @has_regexp_name?()) and @name() isnt 'List'
    
  is_named: (n) =>
    return true if @name() is n
    return false unless @has_regexp_name()
    @name().test n
    

module.exports = Var
module.exports.new_local = (args...) ->
  v = new Var(args...)
  v.is_local_only true
  v
