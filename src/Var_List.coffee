rw = require "rw_ize"
_  = require "underscore"
Var = require "i_love_u/lib/Var"

# Can hold vars and other lists of vars.
class Var_List

  @counter = 0

  rw.ize(this)
  @read_able "object_id", "name", "vars", "parent_list", 'calling_list'
  @read_able_bool "is_a_var_list"

  @private_ize "scope"
  
  constructor: (new_name, parent_list, calling_list) ->
    @rw 'object_id',    ++Var_List.counter
    @rw 'name',         new_name
    @rw 'vars',         {}
    @rw 'parent_list',  (parent_list || null)
    @rw 'calling_list', (calling_list || null)
    @rw 'is_a_var_list',  true
    
    @scope_is 'local'

  
  # ==============================================================
  #                      Push/Pop/Get Ops
  # ==============================================================

  is_named: (n) ->
    not not @get(b)
    
  get_or_throw: (name) ->
    @get(name) or throw new Error("Variable not found: #{name}")
    
  get: (name) ->
    if @to_local()
      _.find @vars, (v) ->
        v.is_named(name)
    else
      target = @scope().get(name)
      return target if target and target.is_import_able()
      
  push_name_and_value: (name, val) ->
    if arguments.length isnt 2
      throw new Error "Arguments length can only be 2: #{arguments}"
    @push(new Var name, val)

  push: (v) ->
    return(@scope().push(v)) unless @to_local()
    
    v.belongs_to @object_id()
    if @vars()[ v.name() ]
      throw new Error "Name for var already defined: #{v.name()}"
    @vars()[v.name()] = v
      
      
  pop: (n) ->
    return @scope.pop(n) unless @to_local()
    
    throw new Error "Not found: #{n}" unless @is_named(n)
    val = @vars()[n]
    delete @vars()[n]
    val
      
  # ==============================================================
  #                        Scope Ops.
  # ==============================================================
  
  scope_is: (target) ->
    switch target
      when "local", "outside", "calling"
        @scope target
      when null, undefined
        @read 'scope'
      else
        throw new Error "Unknown scope: #{target}"

  scope: () ->
    if @to_local()
      null
    else if @to_outside()
      @outside_list()
    else if @to_calling()
      @calling_list()
    else
      throw new Error "Unknown scope: #{@read 'scope'}"

  to_local: () ->
    @read('scope') is "local"
    
  to_outside: () ->
    @read('scope') is "outside"
    
  to_calling: () ->
    @read('scope') is "calling"


module.exports = Var_List
