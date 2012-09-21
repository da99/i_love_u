
rw = require "rw_ize"
_  = require "underscore"

class Var

  rw.ize this
  @read_able "name", "value"
  @read_write_able "is_import_able", "belongs_to"
  

  constructor: (name, val) ->
    @rw "name",           name
    @rw "value",          val
    @rw "is_import_able", true
    @rw "belongs_to",     "no-one"

  has_regexp_name: () ->
    _.isRegExp(@name())

  is_named: (n) =>
    return true if @name() is n
    return false unless @has_regexp_name()
    @name().test n
    

module.exports = Var
