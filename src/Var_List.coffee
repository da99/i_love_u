rw = require "rw_ize"
_  = require "underscore"
Var  = require "i_love_u/lib/Var"
Line = require "i_love_u/lib/Line"
Arguments_Match = require "i_love_u/lib/Arguments_Match"

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
    
  array: (type) ->
    type = 'all' if arguments.length is 0
    vars = switch type
      when 'vars', 'var_values'
        arr = []
        for k, v of @vars() 
          if v.is_user_defined() 
            if type is 'var_values'
              arr.push v.value()
            else
              arr.push v
        arr
      when 'procedures'
        ( v for k, v of @vars() when v.is_a_procedure?() )
      when 'all'
        @vars()
      else
        throw new Error "Unknown var type: #{type}"
      
    if not @env().is_read_local()
      vars =  @env().read().vars().array(type).concat vars
    vars
    
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
    
    @get(name, line) or name
      
  get_vars_with: (name, line) ->
    _vars = null
    
    if not @env().envs().is_read_local()
      _vars = @env().envs().read().vars().get_vars_with(name, line)
  
    if not _vars
      _vars = if @vars()[name] 
        @vars()
      else
        found = _.find @pattern_based(), (v) ->
          v.is_named(name)
        found and @vars()
        
          
    _vars
    
  get: (name, line) ->
    vars = @get_vars_with(name, line)
    return vars unless vars
    return vars[name] unless vars[name]
    v = vars[name]
    return null if v and v.is_local_only() and line.calling_env() isnt @env()
    v
      
  push_name_and_value: (name, val) ->
    if arguments.length isnt 2
      throw new Error "Arguments length can only be 2: #{arguments}"
    @push(new Var name, val)

  push: (v) ->
    if arguments.length isnt 1
      throw new Error ".push only accepts one argument."
    if not @env().is_write_local() 
      return @env().envs().write().vars().push v
    
    if @has_named v.name()
      throw new Error "Name for var already defined: #{v.name()}"
    
    @vars()[v.name()] = v

    if v.value().is_a_procedure?()
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
      
  update_name_and_value: (name, val) ->
    vars = @get_vars_with(name)
    if not vars
      @get_or_throw(name)
    vars[name] = new Var(name, val)
    vars[name]

      
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
  #                        Run Procs
  # ==============================================================
  
  run_line_tokens: ( pair ) ->
    match = new Arguments_Match(new Line(pair, @env()))
    if not @env().is_read_local()
      match = @env().envs().read().run_line_tokens( pair )
      
    return match if match.is_full_match?()
    
    me = this
    
    if match 
      line          = match.line()
      is_full_match = match.is_full_match()
      partial_match = match.is_a_match()
    else
      line = new Line( pair, env ) 
      is_full_match = false
      partial_match = false

    loop 
      is_any_match  = false
      
      for proc in @procs()
        loop
          match = new Arguments_Match( line, proc)
          break if not match.is_a_match()
            
          partial_match = is_any_match = true
          if match.is_full_match()
            is_full_match = true
            break
          
        break if is_full_match
        
      break if is_full_match
      break if not is_any_match
    
    match
       

module.exports = Var_List

    

