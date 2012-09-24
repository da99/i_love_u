rw = require "rw_ize"
_  = require "underscore"
Var  = require "i_love_u/lib/Var"
Line = require "i_love_u/lib/Line"
Arguments_Match = require "i_love_u/lib/Arguments_Match"

class Message

  rw.ize this

  @read_write_able_bool "is_done"
  @read_write_able "name", "list", "action"

  constructor: (yield_to) ->
    yield_to(this)

  action: () ->
    if arguments.length is 1
      @_action_ = _.first arguments
      if @_action_ isnt "reading" and @_action_ isnt "writing"
        throw new Error "Unknown action: #{@_action_}"
    @_action_

  var: () ->
    if arguments.length is 1
      @_var_ = _.first arguments
      @name( @_var_.name() ) unless @name()
    @_var_

  line: () ->
    if arguments.length is 1
      @_line_ = _.first arguments
      @calling_env(@_line_.calling_env()) unless @calling_env()
    @_line_
    
  is_a_message: () ->
    true

  is_for_reading: () ->
    @action() is 'reading'
    
  is_for_writing: () ->
    @action() is 'writing'

  value: (val) ->
    if arguments.length is 1
      @var(new Var @name(), val)
    @var()

  
# Can hold vars and other lists of vars.
class Var_List

  @counter = 0

  rw.ize(this)
  @read_able "env", "object_id", "vars", "procs", "pattern_based"
  
  constructor: (env) ->
    @rw 'env',           env
    @rw 'object_id',     ++Var_List.counter
    @rw 'kv',          {}
    @rw 'procs',         []
    @rw 'pattern_based', {}
    
  is_a_var_list: () ->
    true
    
  array: (type) ->
    type = 'all' if arguments.length is 0
    vars = switch type
      when 'vars', 'var_values'
        arr = []
        for k, v of @kv() 
          if v.is_user_defined() 
            if type is 'var_values'
              arr.push v.value()
            else
              arr.push v
        arr
      when 'procedures'
        ( v for k, v of @kv() when v.is_a_procedure?() )
      when 'all'
        ( v for k, v of @kv() )
      else
        throw new Error "Unknown var type: #{type}"
      
    if not @env().is_read_local()
      vars =  @env().read().vars().array(type).concat vars
    vars
    
  # ==============================================================
  #                      Push/Remove/Get Ops
  # ==============================================================

  to_message: () ->
    unk = arguments[0]
    if _.isString(unk)
      name = unk
      unk = (mess) ->
        mess.name name
    m = if unk.is_a_message?()
      unk
    else
      new Message (mess) ->
        unk(mess)
        mess.calling_env @env() unless mess.calling_env()
    f = arguments[1]
    f(m) if f
    m
    
  has_named: (yield_to) ->
    @find_for(yield_to).is_done()
      
  find_for_or_throw: (unk) ->
    i = @find_for(unk)
    return i if i.is_done()
    throw new Error "No var named: #{i.name()}"
  
  find_for: (unk) ->
    m      = @to_message(unk)
    action = m.action()
    name   = m.name()
    calling_env = m.calling_env()

    v = if @kv()[name]
      @kv()[name]
    else if m.is_for_reading()
      _.find @pattern_based(), (_v_) ->
        _v_.is_named(name)
        
    if v and v.is_local_only() and calling_env isnt @env()
      v = undefined
      
    if v
      m.var     v
      m.list    this
      m.is_done true
      return m

    if not @env().is_write_local()
      m = @env().write().find_for(m)
      return m if m.is_done()
        
    if m.is_for_reading() and not @env().is_read_local() 
      m = @env().read().find_for(m)
      return m if m.is_done()

    m

  get_or_throw: (yield_to) ->
    @find_for_or_throw(yield_to).var()
    
  get_if_data: (yield_to) ->
    m = @find_for yield_to 
    if m.is_done()
      m.var()
    else
      m.name()
    
  get: (yield_to) ->
    i = @find_for yield_to
    i.is_done() and i.var()

  push_name_and_value: (n, v) ->
    @push (mess) ->
      mess.name n
      mess.value v

  push: (yield_to) ->
    if yield_to.is_a_var?()
      _var_ = yield_to
      yield_to = (mess) ->
        mess.var _var_
    m = @to_message yield_to, (mess) ->
      mess.action "writing"
      
    if not @env().is_write_local() 
      return @env().envs().write().push m
      
    if @find_for(m).is_done()
      throw new Error "Name for var already defined: #{old.name()}"
    
    v    = m.var()
    name = m.name()
    proc = v.value()
    @kv()[name] = v
    m.is_done true

    if proc.is_a_procedure?()
      switch proc.position()
        when 'top'
          @procs().unshift proc
        when 'middle'
          @procs().splice(Math.ceil( @procs().length / 2 ), 0, proc)
        when 'bottom'
          @procs().push proc
        else
          throw new Error "Unknown position for \"#{proc.pattern()}\": #{proc.position()}"
        
    m.var()
      
  update: (yield_to) ->
    m = @to_message yield_to, (mess) ->
      mess.action "writing"

    @find_for_or_throw(m).list().kv()[name] = m.var()
    m.is_done true
    m.var()

      
  delete: (yield_to) ->
    m = @to_message yield_to, (mess) ->
      mess.action "writing"
    m = @find_for_or_throw m
    delete m.list()[m.name()]
    
    # ==== Remove if in procedures list.
    proc = m.var()
    proc_list = m.list().procs()
    if proc.is_a_procedure?()
      for p, i in proc_list
        break if p is proc
      if i > -1 
        proc_list.splice(i,1)
        
    m.var()
    

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

    

