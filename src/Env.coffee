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
  
  @Env_Names = ["Local-Env", "Outside-Env", "Outside-Local-Env", "Page-Env"]
  for v in @Env_Names
    this[v.replace(/-/g, '_')] = new Function """
      return "#{v}";
    """
    
  @validate_name = (e) ->
    if not (e in @Env_Names)
      throw new Error "Invalid env: #{e}"
    e

  @base: () ->
    if not @_base_
      e = new Env()
      Base_Procs.i_love_u(e)
      Base_Data.i_love_u(e)
      @_base_ = e
    @_base_


  # ==============================================================
  #                      "Instance" Functionality
  # ==============================================================
  
  rw.ize(this)
  @read_able       "vars", "envs", "loop_total", "code", "original_code", "outside", "local"
  @read_write_able "address"
  
  constructor: ( yield_to ) ->
    @base = {}
    @base["vars"] = {
      "top-envs": [] 
      "bottom-envs": []
      "local-vars": []
    }
    @base[ Env.Local_Env() ] = this
    
    @base["functions"] =[]
    @base["ilu"] = {"loop_total": 0} 
    
    yield_to(this) if yield_to
    @read_var("top-envs").push Env.base()
        
  # ==============================================================
  #                      Manage Vars
  # ==============================================================
    
  vars: () ->
    @base["vars"]

  force_update_var: (name, val) ->
    @base["vars"][name] = val
    
  force_delete_var: (name, val) ->
    delete @base["vars"][name]
    
  create_var: (name, val) ->
    if _.has(@vars(), name)
      throw new Error "Var already defined: #{name}"
    
    switch name
      when "code"
        str = val
        if not _.isString(str) 
          str = str.text()
          @vars()["original_code"] = str
          @vars()[name] = str.standardize()
          @vars()[name]
      else
        @vars()[name] = val

  has_var: (name) ->
    _.has @base["vars"], name
    
  require_var: (name) ->
    if not @has_var name
      throw new Error "Var not defined: #{name}"
    @base["vars"][name]
    
  read_var: (name) ->
    @require_var name
    
  update_var: (name, val) ->
    @require_var name
    @base["vars"][name]

  delete_var: (name) ->
    @require_var name
    delete @base["vars"][name]

  # ==============================================================
  #                      Forwarded functions
  # ==============================================================
  
  
  meths = {
    'vars': ['get', 'get_if_data', 'run_line_tokens', 'push', 'push_name_and_value', 'update_name_and_value', 'delete']
  }
  for prop, arr of meths
    for meth in arr
      this.prototype[meth] = new Function """
        return this.local().#{prop}().#{meth}.apply( this.local().#{prop}(), Array.prototype.slice.apply(arguments) );
      """

  is_an_env: () ->
    true

  # ==============================================================
  #                      Manage Env
  # ==============================================================

  read_from: () ->
    @_read_from_ ?= Env.Outside_Env()
    if arguments.length is 1
      env = arguments[0]
      @constructor.throw_unless_valid_env env
      @_read_from_ = e
    @_read_from_

  write_to: () ->
    @_write_to_ ?= Env.Local_Env()
    if arguments.length is 1
      env = arguments[0]
      @constructor.throw_unless_valid_env env
      @_write_to_ = e
    @_write_to_

  has_outside: () ->
    (not not @outside()) and @outside().is_an_env?() 
    
  is_page: () ->
    (not not @address())

  is_local_only: () ->
    @is_read_local() and @is_write_local()

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
    
    



