englishy     = require 'englishy'
_            = require 'underscore'
rw           = require 'rw_ize'
Base_Procs   = require "i_love_u/lib/Base_Procs"
Base_Data    = require "i_love_u/lib/Base_Data"
Var_List     = require "i_love_u/lib/Var_List"

exports.Env = class Env
  
  # ==============================================================
  #                      "Class" Functionality
  # ==============================================================
  
  @Envs = "Local-Env", "Outside-Env", "Outside-Local-Env", "Page-Env"
  for v in @Envs
    this[v.replace(/-/g, '_')] = new Function """
      return "#{v}";
    """
  @No_Match   = "no_match"
    
  @throw_unless_valid_env = (e) ->
    if not (e in @Envs)
      throw new Error "Invalid env: #{e}"
    e

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
  @read_able       "vars", "envs", "loop_total", "code", "original_code", "outside", "local"
  @read_write_able "address", "read_from", "write_to"
  
  constructor: (str, outside_env) ->
    if not _.isString(str) 
      str = str.text()
    @rw "original_code",  str
    @rw "code",           str.standardize()
    @rw "outside",        outside_env
    @rw "local",          this
    @rw "loop_total",     0
    @rw "vars",           new Var_List(this)
    @read_from @constructor.Outside_Env()
    @write_to  @constructor.Local_Env()
      
    if not @envs().has_outside()
      for init in @constructor.inits()
        init(this)
    
  is_an_env: () ->
    true

  meths = {
    'vars': ['get', 'get_if_data', 'run_line_tokens', 'push', 'push_name_and_value', 'update_name_and_value', 'delete']
  }
  for prop, arr of meths
    for meth in arr
      this.prototype[meth] = new Function """
        return this.local().#{prop}().#{meth}.apply( this.local().#{prop}(), Array.prototype.slice.apply(arguments) );
      """

  # ==============================================================
  #                      Manage Env
  # ==============================================================

  read_from: () ->
    if arguments.length is 1
      env = arguments[0]
      @constructor.throw_unless_valid_env env
      @write "read_from" e
    @read "read_from"

  write_to: () ->
    if arguments.length is 1
      env = arguments[0]
      @constructor.throw_unless_valid_env env
      @write "write_to" e
    @read "write_to"

  has_outside: () ->
    @outside() and @outside().is_an_env?() 
    
  is_page: () ->
    not @has_outside()

  is_local_only: () ->
    @read_from() is Env.Local_Env() and @write_to() is Env.Local_Env()

  is_read_local: () ->
    @read_from() is Env.Local_Env()

  is_write_local: () ->
    @write_to() is Env.Local_Env()
  
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

    true
    
    
Env.inits Base_Procs.i_love_u, Base_Data.i_love_u



