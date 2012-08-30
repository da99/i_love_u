englishy     = require 'englishy'
string_da99  = require 'string_da99'
funcy_perm   = require 'funcy_perm'
arr_surgeon  = require 'array_surgeon'
_            = require 'underscore'
rw           = require 'rw_ize'
Procedure    = require "i_love_u/lib/Procedure"

if !RegExp.escape
  RegExp.escape= (s) ->
    return s.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&')
  
if !RegExp.captures
  RegExp.captures= ( r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = null
    runs  = 0
    while (match = r.exec(str))
      if runs > 10 and r.lastIndex is 0
        throw new Error("/g flag is not set: #{r}")
      vals ?= []
      vals.push match
      runs += 1
    vals

if !RegExp.first_capture
  RegExp.first_capture= (r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = null
    r.exec(str)
    

exports.Var = class Var
  rw.ize(this)
  @read_able "name", "value", "inherits_from"
  constructor: (n, val) ->
    @rw_data().name  = n
    @rw_data().value = val
    @rw_data().inherits_from = []
    
exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'data', 'procs', 'data', 'scope'
  @read_able 'code', 'original_code'
    
  @add_base_proc: (proc) ->
    @Base_Procs.push proc
    @Base_Procs = @Base_Procs.sort (a, b) ->
      levels = 
        low: 10
        medium: 0
        high: -10
      a_level = levels[a.priority()]
      b_level = levels[b.priority()]
      a_level > b_level

  constructor: (str, env) ->
    @rw_data().original_code = str
    @rw_data().code =  str.standardize()
    @write 'scope', []
    @write 'procs', [].concat(@constructor.Base_Procs)
    @_data_ = if env
      env.data()
    else
      []
    
  add_data: (k, v) ->
    @_data_.push(new Var(k, v))

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
    
  @dynamic_data /^Block_Text_Line_[0-9]+$/, (env, line, block, name) ->
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      val = block.text_line( num )
      # new Var(name, val)
      val

  @dynamic_data /^Block_List_[0-9]+$/, (env, line, block, name) ->
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      str = block.text_line( num ).strip()
      tokens = _.flatten( new englishy.Englishy(str + '.').to_tokens() )
      list = (env.get_if_data(v) for v in tokens)
      list

  dynamic_data: (name, line, block) ->
    func = @constructor.dynamic_data(name)
    func( this, line, block, name )
          
  is_name_of_dynamic_data: (k) ->
    @constructor.is_name_of_dynamic_data(k)
    
  is_name_of_data: (k) ->
    return true if @is_name_of_dynamic_data(k)
    
    val = v for v in @_data_ when v.name() == k
    not not val

  data: ( k, line, block ) ->
    if @is_name_of_dynamic_data(k)
      @dynamic_data(k, line, block)
    else if k
      val = v for v in @_data_ when v.name() is k
      val && val.value()
    else
      vals = (v for v in @_data_ when ("name" of v) and ("value" of v) )
      vals
      @_data_
      
  get_if_data: (name) ->
    if @is_name_of_data(name)
      @data(name) 
    else
      name

  run: () ->
    lines = (new englishy.Englishy @code()).to_tokens()
    me = this
    @compile_sentence_func ?= (memo, proc) ->
      proc.run me, memo
      
    for line_and_block, i in lines
      
      line       = line_and_block[0]
      code_block = line_and_block[1]
      orig_pair  = [ line, code_block ]
      current  = orig_pair
      compiled = null
      matched  = true
      
      while matched
        
        compiled = current

        for proc in @procs()

          matched_to_proc = true
          
          while matched_to_proc
            compiled = @compile_sentence_func(current, proc)
            matched_to_proc = !_.isEqual(compiled, current)
            current = compiled
            
        matched = ! _.isEqual compiled, current 

      if orig_pair.length is compiled.length and _.isEqual(orig_pair, compiled)
        end = if code_block
          ":"
        else
          "."
        throw new Error("No match for: #{orig_pair[0].join(" ")}#{end}")

        
    @data()
  
    
    
md_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
md_num.write 'priority', 'high'
md_num.write 'procedure', (match) ->
  m = match.args()[0]
  op= match.args()[1]
  n = match.args()[2]
  switch op
    when '*'
      match.replace( parseFloat(m) * parseFloat(n) )
    when '/'
      match.replace( parseFloat(m) / parseFloat(n) )
    else
      match.is_a_match(false)
  match

as_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
as_num.write 'procedure', (match) ->
  m = match.args()[0]
  op= match.args()[1]
  n = match.args()[2]
  switch op
    when '+'
      match.replace( parseFloat(m) + parseFloat(n) )
    when '-'
      match.replace( parseFloat(m) - parseFloat(n) )
    else
      match.is_a_match false
      
  match

  
word_is_word = new Procedure "!>WORD< is: !>ANY<."
word_is_word.write 'procedure', (match) ->
  name = _.first match.args() 
  val  = _.last  match.args()
  match.env().add_data name, val
  match.replace val
  match
     
if_true = new Procedure "If !>true<:"
if_true.write 'procedure', (match) ->
  luv = new i_love_u(match.code().text(), match.env())
  luv.run()
  match.replace  true
  match.env().scope().push true
  match

if_false = new Procedure "If !>false<:"
if_false.write 'procedure', (match) ->
  match.replace  false
  match.env().scope().push false
  match


else_false = new Procedure "else:"
else_false.write 'procedure', (match) ->
  if _.last(match.env().scope()) is false
    luv = new i_love_u(match.code().text(), match.env())
    luv.run()
    match.replace false
  else
    match.replace true
  match


i_love_u.add_base_proc  if_true
i_love_u.add_base_proc  if_false
i_love_u.add_base_proc  else_false
i_love_u.add_base_proc  as_num
i_love_u.add_base_proc  md_num
i_love_u.add_base_proc  word_is_word


