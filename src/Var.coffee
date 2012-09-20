
rw = require "rw_ize"
_  = require "underscore"

class Var

  rw.ize this
  @read_able "notifys_list", "name", "value"
  @read_write_able "is_import_able", "has_regexp_name", "belongs_to"

  constructor: (name, val) ->
    @rw "name",           name
    @rw "value",          val
    @rw "notifys_list",   []
    @rw "is_import_able", true
    @rw "has_regexp_name", _.isRegExp(name)
    @rw "belongs_to", "no-one"

  is_named: (n) =>
    return true if @name() is n
    return false unless @has_regexp_name()
    @name().test n
    
  notify_to: () ->
    switch arguments.length
      when 1, 2, 3, 4
      else
        throw new Error "Unknown arguments: #{(v for v in arguments)}"
      
    target = arguments[0]
    action = arguments[1]
    key    = arguments[2]
    value  = arguments[3]
    @notifys_list.push [target, action, key, value]




module.exports = Var
