englishy     = require 'englishy'
string_da99  = require 'string_da99'
funcy_perm   = require 'funcy_perm'
arr_surgeon  = require 'array_surgeon'
_            = require 'underscore'
cloneextend  = require "cloneextend"
rw           = require 'rw_ize'
humane_list  = require 'humane_list'
XRegExp      = require('xregexp' ).XRegExp
Line         = require 'i_love_u/lib/Line'
Procedure    = require "i_love_u/lib/Procedure"
Base_Procs   = require "i_love_u/lib/Base_Procs"

Arguments_Match = require "i_love_u/lib/Arguments_Match"
Var_List  = require "i_love_u/lib/Var_List"
LOOP_LIMIT   = 10123

if !RegExp.captures
  RegExp.captures= ( r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = []
    pos   = 0
    while (match = XRegExp.exec( str, r, pos, 'sticky') )
      pos = match.index + match[0].length
      match.shift()
      ( vals.push(v) for v in match )
      
    return null if vals.length is 0 
    vals

if !RegExp.first_capture
  RegExp.first_capture= (r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = null
    r.exec(str)
    

exports.Var = class Var
  rw.ize(this)
  @read_able "name", "inherits_from"
  @read_write_able "value"
  @read_able_bool "is_a_var"
  constructor: (n, val) ->
    @rw 'name', n
    @rw "value",  val
    @rw "inherits_from",  []
    @rw "is_a_var",  true
    
exports.i_love_u = class i_love_u
  
  @No_Match   = "no_match"
  @Base_Procs = []
  @Base_Data  = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'data', 'procs', 'data', 'scope', 'loop_total'
  @read_able 'code', 'original_code', 'eval_ed'
    
  @add_base_data: (name, val) ->
    @Base_Data.push [name, val]

  @add_base_proc: (proc) ->
    switch proc.position()
      when 'top'
        @Base_Procs.unshift proc
      when 'middle'
        @Base_Procs.splice(Math.ceil( @Base_Procs.length / 2 ), 0, proc)
      when 'bottom'
        @Base_Procs.push proc
      else
        throw new Error "Unknown position for \"#{proc.pattern()}\": #{proc.position()}"

  constructor: (str, env) ->
    if not _.isString(str) 
      str = str.text()
    @rw "original_code",  str
    @rw "code",   str.standardize()
    @rw "eval_ed",  []
    @scope []
    @procs [].concat(@constructor.Base_Procs)
      
    if env
      @rw "loop_total", env.loop_total()
      @_data_ = env.data()
    else
      @rw "loop_total", 0
      @_data_ = []
      
      for pair in @constructor.Base_Data
        @add_data( pair... )
    
  @is_name_of_dynamic_data: (name) ->
    (not not @dynamic_data(name))
        
  @dynamic_data: (args...) ->
    @_dynamic_data_ ?= []
    
    if args.length is 0
      @_dynamic_data_
    else if args.length is 1
      name = args[0]
      func = kv[1] for kv in @_dynamic_data_ when name is kv[0] or kv[0].test(name)
      func
    else if args.length is 2
      @_dynamic_data_.push [args[0], args[1]]
    else
      throw new Error("Unknown args: #{args}")
    
  @dynamic_data /^Block_Text_Line_[0-9]+$/, (name, env, line) ->
    block = line.block()
    if !block
      throw new Error("Block is not defined.")
    num = parseInt name.split('_').pop()
    val = block.text_line( num )

  @dynamic_data /^Block_List_[0-9]+$/, (name, env, line) ->
    block = line.block()
    if !block
      throw new Error("Block is not defined.")
    num = parseInt name.split('_').pop()
    str = block.text_line( num ).strip()
    tokens = _.flatten( new englishy.Englishy(str + '.').to_tokens() )
    list = []
    for v in tokens
      if v.is_quoted()
        list.push v.value()
      else
        list.push env.get_if_data(v.value(), line)
    list

  dynamic_data: (name, line) ->
    func = @constructor.dynamic_data(name)
    func( name, this, line )
          
  is_name_of_dynamic_data: (k) ->
    @constructor.is_name_of_dynamic_data(k)
    
  is_name_of_data: (k) ->
    return true if @is_name_of_dynamic_data(k)
    
    val = v for v in @_data_ when v.name() == k
    not not val
    
  add_data: (k, v) ->
    @_data_.push(new Var(k, v))

  update_data: (k, new_v) ->
    val_i = i for v, i in @_data_ when v.name() is k
    if isNaN(parseInt(val_i))
      throw new Error("No data named: #{k}")
    
    if new_v.is_a_var
      @_data_[val_i] = new_v
    else
      @_data_[val_i].value new_v

  delete_data: (name) ->
    if not @is_name_of_data(name)
      throw new Error("Data does not exist: #{name}.") 
    pos = k for v, k in @_data_ when v.name() is name
    @_data_.splice pos, 1

  data: ( k, line ) ->
    if @is_name_of_dynamic_data(k)
      @dynamic_data(k, line)
    else if k
      val = v for v in @_data_ when v.name() is k
      val && val.value()
    else
      vals = (v for v in @_data_ when ("name" of v) and ("value" of v) )
      vals
      @_data_
      
  get_if_data: (name, line) ->
    if not line
      throw new Error "Line is required."
    if @is_name_of_data(name, line)
      @data name, line
    else
      name

  record_loop: (text) ->
    @loop_total( @loop_total() + 1 )
    if @loop_total() > LOOP_LIMIT
      throw new Error("Loop limit exceeded #{LOOP_LIMIT} using: #{text}.")
    @loop_total()
    
  run_tokens: (args...) ->
    line  = new Line( args... ) 
    is_full_match = false
    partial_match = false
    me       = this

    loop 
      is_any_match  = false
      
      for proc in @procs()
        loop
          match = new Arguments_Match(this, line, proc)
          break if not match.is_a_match()
            
          partial_match = is_any_match = true
          if match.is_full_match()
            is_full_match = true
            break
          
        break if is_full_match
        
      break if is_full_match
      break if not is_any_match
    
    results = 
      is_match:      partial_match
      is_full_match: is_full_match
      compiled:      line.pair()
      
  run: () ->
    lines = (new englishy.Englishy @code()).to_tokens()
      
    for line_and_block, i in lines
      results = @run_tokens( line_and_block[0], line_and_block[1] )
          
      if not results.is_any_match or not results.is_full_match
        end = if line_and_block[1]
          ":"
        else
          "."
        
        line = "#{englishy.Stringy.to_strings(line_and_block[0]).join(" ")}#{end}"
        if not results.is_match
          throw new Error("No match for: #{line}")
        if not results.is_full_match
          throw new Error("No full match: #{line} => #{results.compiled[0].join(" ")}#{end}")

      @eval_ed().push results.compiled

    true
  
  
Base_Procs.i_love_u(exports.i_love_u)

# Add basic Nouns:
list_noun = 
  
  is_a_noun: () ->
    true
    
  target: () ->
    @_target_ ?= new humane_list()
    
  insert: (pos, val) ->
    @target().push( pos, val )

  values: () ->
    @target().values()

  
i_love_u.add_base_data "List", list_noun



