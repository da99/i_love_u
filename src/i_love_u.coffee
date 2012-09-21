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
Base_Data    = require "i_love_u/lib/Base_Data"

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
  
  # ==============================================================
  #                      "Class" Functionality
  # ==============================================================
  
  @No_Match   = "no_match"
  @_procs_ = []
  @_data_  = []

    
  @data: (name, val) ->
    if arguments.length is 0
      return @_data_  
    
    else if arguments.length is 1
      _.find @_data_, (v) ->
        v[0] is name
        
    else 
      @_data_.push( new Var(name, val) )

  @procs: (proc) ->

    return @_procs_ if arguments.length is 0

    switch proc.position()
      when 'top'
        @_procs_.unshift proc
      when 'middle'
        @_procs_.splice(Math.ceil( @_procs_.length / 2 ), 0, proc)
      when 'bottom'
        @_procs_.push proc
      else
        throw new Error "Unknown position for \"#{proc.pattern()}\": #{proc.position()}"

      
  # ==============================================================
  #                      "Instance" Functionality
  # ==============================================================
  
  rw.ize(this)
  @read_able       "outside_scope", 'pattern', 'data', 'procs', 'data', 'scope', 'loop_total'
  @read_write_able "address"
  @read_able       'code', 'original_code', 'eval_ed'
  
  constructor: (str, env) ->
    if not _.isString(str) 
      str = str.text()
    @rw "original_code",  str
    @rw "code",           str.standardize()
    @rw "eval_ed",        []
    @rw 'scope',          []
    @rw "loop_total",     0
    @_data_ = []
      
    if env
      @rw  'procs', []
      @rw  'outside_scope', env
    else
      @rw  'procs', [].concat(@constructor.procs())
      @rw  'outside_scope', "none"
      for pair in @constructor.data()
        @add_data( pair... )
    
  is_top_most_scope: () ->
    @outside_scope() is 'none'

  # ==============================================================
  #                      Data Read/Write
  # ==============================================================
  
  is_name_of_data: (k) ->
    val = v for v in @_data_ when v.is_named(k)
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

  # ==============================================================
  #                      Functions & Procedures
  # ==============================================================
  
  
  record_loop: (text) ->
    @loop_total( @loop_total() + 1 )
    if @loop_total() > LOOP_LIMIT
      throw new Error("Loop limit exceeded #{LOOP_LIMIT} using: #{text}.")
    @loop_total()
    
  run_tokens: (args...) ->
    line          = new Line( args... ) 
    is_full_match = false
    partial_match = false
    me            = this

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
Base_Data.i_love_u(exports.i_love_u)



