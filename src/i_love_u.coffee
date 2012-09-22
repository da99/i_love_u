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
Var       = require "i_love_u/lib/Var"
Var_List  = require "i_love_u/lib/Var_List"
Env_List  = require "i_love_u/lib/Env_List"
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
  @read_able       'vars', 'envs', 'loop_total'
  @read_write_able "address"
  @read_able       'code', 'original_code', 'eval_ed'
  
  constructor: (str, outside_env) ->
    if not _.isString(str) 
      str = str.text()
    @rw "original_code",  str
    @rw "code",           str.standardize()
    @rw "eval_ed",        []
    @rw 'envs',           new Env_List(this, outside_env)
    @rw "loop_total",     0
    @rw "vars",           new Var_List(this)
      
    if not @envs().has_outside()
      for init in @constructor.inits()
        init(this)
    
  meths = {
    'vars': ['get', 'get_if_data', 'run_line_tokens', 'push', 'push_name_and_value'],
    'envs': ['is_read_local', 'is_write_local', 'has_outside', 'read', 'write']
  }
  for prop, arr of meths
    for meth in arr
      this.prototype[meth] = new Function """
        return this.#{prop}().#{meth}.apply( this.#{prop}(), Array.prototype.slice.apply(arguments) );
      """
  # ==============================================================
  #                      Functions & Procedures
  # ==============================================================
  
  record_loop: (text) ->
    @loop_total( @loop_total() + 1 )
    if @loop_total() > LOOP_LIMIT
      throw new Error("Loop limit exceeded #{LOOP_LIMIT} using: #{text}.")
    @loop_total()
    
  run: () ->
    lines = (new englishy.Englishy @code()).to_tokens()
      
    for line_and_block, i in lines
      match = @run_line_tokens( line_and_block )
          
      if (not match.is_a_match?()) or not match.is_full_match?()
        end = if line_and_block[1]
          ":"
        else
          "."
        
        line = "#{englishy.Stringy.to_strings(line_and_block[0]).join(" ")}#{end}"
        if not match.is_a_match?()
          throw new Error("No match for: #{line}")
        if match and not match.is_full_match()
          throw new Error("No full match: #{line} => #{match.line().line().join(" ")}#{end}")

      @eval_ed().push match.line().line() if match

    true
  
  
i_love_u.inits Base_Procs.i_love_u, Base_Data.i_love_u



