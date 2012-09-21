rw = require "rw_ize"
_  = require "underscore"
Var = require "i_love_u/lib/Var"

# Can hold vars and other lists of vars.
class Var_List

  @counter = 0

  rw.ize(this)
  @read_able "env", "object_id", "vars", "procs", "pattern_based"
  
  constructor: (env) ->
    @rw 'env',           env
    @rw 'object_id',     ++Var_List.counter
    @rw 'vars',          {}
    @rw 'procs',         []
    @rw 'pattern_based', {}
    
  is_a_var_list: () ->
    true
    
  # ==============================================================
  #                      Push/Remove/Get Ops
  # ==============================================================

  has_named: (args...) ->
    not not @get(args...)

  get_or_throw: (name) ->
    @get(name) or throw new Error("Variable not found: #{name}")
    
  get_if_data: (name, line) ->
    if not line.is_a_line?()
      throw new Error "Line is required."
    
    get(name, line) or name
      
  get: (name, line) ->
    calling_env = line.env()
    target = null
    
    if not @env().env_list().is_local_read()
      target = @env().env_list().read().get(name, line)
  
    if not target
      target = if @vars[name] 
        @vars[name]
      else
        _.find @pattern_based(), (v) ->
          v.is_named(name)
          
    if (not target.is_import_able()) and target.env() isnt calling_env
      target = undefined

    target
      
  push_name_and_value: (name, val) ->
    if arguments.length isnt 2
      throw new Error "Arguments length can only be 2: #{arguments}"
    @push(new Var name, val)

  push: (v) ->
    return(@env().push(v)) unless @to_local()
    
    v.belongs_to @object_id()
    if @vars()[ v.name() ]
      throw new Error "Name for var already defined: #{v.name()}"
    @vars()[v.name()] = v

    if v.value().is_a_procedure()
      proc = v.value()
      switch proc.position()
        when 'top'
          @procs().unshift proc
        when 'middle'
          @procs().splice(Math.ceil( @procs().length / 2 ), 0, proc)
        when 'bottom'
          @procs().push proc
        else
          throw new Error "Unknown position for \"#{proc.pattern()}\": #{proc.position()}"

    v
      
      
  remove: (n) ->
    return @scope.remove(n) unless @to_local()
    
    throw new Error "Not found: #{n}" unless @is_named(n)
    val = @vars()[n]
    delete @vars()[n]
    
    # ==== Remove if in procedures list.
    proc = val and val.value()
    if proc.is_a_procedure?()
      for p, i in @procs()
        break if p is proc
      if i > -1 
        @procs().splice(i,1)
        
    val
      
  # ==============================================================
  #                        Scope Ops.
  # ==============================================================
  

module.exports = Var_List

    

