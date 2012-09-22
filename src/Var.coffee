
rw = require "rw_ize"
_  = require "underscore"

class Var

  rw.ize this
  @read_able "name", "value"
  @read_write_able "is_local_only", "belongs_to"
  

  constructor: (name, val) ->
    @rw "name",           name
    @rw "value",          val
    @rw "is_local_only", true
    @rw "belongs_to",     "no-one"

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
