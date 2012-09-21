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
    
  @inits: () ->
    @_inits_ ?= []
    if arguments.length isnt 0
      for v in arguments
        @_inits_.push v
      @_inits_ = _.unique(@_inits_)
    @_inits_


      
  # ==============================================================
  #                      "Instance" Functionality
  # ==============================================================
  
  rw.ize(this)
  @read_able       "outside_scope", 'vars', 'scope', 'loop_total'
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
    @_vars_ = new Var_List(this)
      
    if env
      @rw  'outside_scope', env
    else
      @rw  'outside_scope', "none"
      for init in @constructor.inits()
        init(this)
    
  is_top_most_scope: () ->
    @outside_scope() is 'none'


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
  
  
i_love_u.inits Base_Procs.i_love_u, Base_Data.i_love_u



