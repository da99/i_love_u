
rw = require "rw_ize"
_  = require "underscore"

class Var

  rw.ize this
  @read_able "name", "value"
  @read_write_able "is_local_only", "regexp"
  

  constructor: (name, val, yield_to) ->
    @rw "name",           name
    @rw "value",          val
    @rw "is_local_only",  false
    yield_to(this) if yield_to

  has_regexp_name: () ->
    _.isRegExp(@regexp())

  is_a_var: () ->
    true

  is_user_defined: () ->
    (not @value().is_a_procedure?()) and (not @has_regexp_name?()) and @name() isnt 'List'
    
  is_named: (n) =>
    return true if @name() is n
    return false unless @has_regexp_name()
    @regexp().test n
    

module.exports = Var
module.exports.to_var = (args) ->
  switch args.length
    when 2
      new Var args[0], args[1]
    when 1
      if args[0].is_a_var?()
        v
      else
        throw new Error "Unknown argument: #{args[0]}"
    else
      throw new Error "Unknown arguments: #{Array.prototype.slice.apply args}"

module.exports.new_local = (args...) ->
  v = new Var(args...)
  v.is_local_only true
  v
