rw = require "rw_ize"
_  = require "underscore"
Var = require "i_love_u/lib/Var"

class Var_List

  rw.ize(this)
  @read_able "name", "vars"
  @read_write_able "is_import_able"
  
  constructor: (new_name) ->
    @rw_data 'name',    new_name
    @rw_data 'vars',    {}
    @rw_data 'is_import_able', false

  push: (name, val) ->
    if arguments.length isnt 2
      throw new Error "Arguments length can only be 2: #{arguments}"
    v = new Var(name, val)
    @push_var(v)


  push_var: (v) ->
    if @vars()[v.name()]
      throw new Error "Name for var already defined: #{v.name()}"
    
    @vars()[k] = v

  get: (name) ->
    target = _.find @d, (v) ->
      v.is_named name

  get_or_throw: (name) ->
    @get(name) or throw new Error("Variable not found: #{name}")

  is_named: (n) ->
    @name() is n

