englishy     = require 'englishy'
string_da99  = require 'string_da99'
funcy_perm   = require 'funcy_perm'
arr_surgeon  = require 'array_surgeon'
_            = require 'underscore'
rw           = require 'rw_ize'
Procedure    = require "i_love_u/lib/Procedure"
LOOP_LIMIT   = 10123
if !String.prototype.remove_quotes
  String.prototype.is_ilu = () ->
    _.first(this) is '"' and  _.last(this) is '"'
  String.prototype.remove_quotes = () ->
    if this.is_ilu()
     return this.replace(/^"/, "").replace(/"$/, "")
    this
    
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
    
comparison_type_cast = (v) ->
  v = if _.isString(v)
    if v is "true"
      true
    else if v is "false"
      false
    else if not _.isNaN(v)
      parseFloat(v)
    else
      v
  else if _.isNumber(v)
    v
  else if _.isBoolean(v)
    v
  else
    throw new Error("Can't convert value into type for comparison: #{v}")

compare = (op, raw_r, raw_l) ->
  r = comparison_type_cast(raw_r)
  l = comparison_type_cast(raw_l)
  ans = switch op
    when ">"
      r > l
    when "<"
      r < l
    when ">="
      r >= l
    when "<="
      r <= l
    when "="
      r is l
    when "!="
      r isnt l
    else
      throw new Error("Unknown comparison operation: #{op} for #{r}, #{l}")
    
  return ans

exports.Var = class Var
  rw.ize(this)
  @read_able "name", "inherits_from"
  @read_write_able "value"
  @read_able_bool "is_a_var"
  constructor: (n, val) ->
    @rw_data().name  = n
    @rw_data().value = val
    @rw_data().inherits_from = []
    @rw_data().is_a_var = true
    
exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'data', 'procs', 'data', 'scope', 'loop_total'
  @read_able 'code', 'original_code', 'eval_ed'
    
  @add_base_proc: (proc) ->
    @Base_Procs.push proc
    @Base_Procs = @Base_Procs.sort (a, b) ->
      levels = 
        before_variables: 30
        last: 20
        low: 10
        medium: 0
        high: -10
      a_level = levels[a.priority()]
      b_level = levels[b.priority()]
      a_level - b_level

  constructor: (str, env) ->
    @rw_data().original_code = str
    @rw_data().code =  str.standardize()
    @rw_data().eval_ed = []
    @write 'scope', []
    @write 'procs', [].concat(@constructor.Base_Procs)
    if env
      @rw_data().loop_total = env.loop_total()
      @_data_ = env.data()
    else
      @rw_data().loop_total = 0
      @_data_ = []
    
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
    
  add_data: (k, v) ->
    @_data_.push(new Var(k, v))

  update_data: (k, new_v) ->
    val_i = i for v, i in @_data_ when v.name() is k
    if isNaN(parseInt(val_i))
      throw new Error("No data named: #{k}")
    
    if new_v.is_a_var
      @_data_[val_i] = new_v
    else
      @_data_[val_i].write "value", new_v

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

  run_tokens: (line, code_block) ->
    orig_pair  = [ line, code_block ]
    current    = orig_pair
    is_full_match = false
    partial_match = false
    me       = this

    loop 
      
      is_any_match  = false
      
      for proc in @procs()
        loop
          match = proc.run me, current
          break if not match
          partial_match = is_any_match = true
          current = [match.line(), match.code()]
          if match.is_full_match()
            is_full_match = true
            break
        break if is_full_match

      break if not is_any_match
    
    results = 
      is_match:      partial_match
      is_full_match: is_full_match
      compiled: current
      
  run: () ->
    lines = (new englishy.Englishy @code()).to_tokens()
      
    for line_and_block, i in lines
      results = @run_tokens( line_and_block[0], line_and_block[1] )
          
      if not results.is_any_match or not results.is_full_match
        end = if line_and_block[1]
          ":"
        else
          "."
        line = "#{line_and_block[0].join(" ")}#{end}"
        if not results.is_match
          throw new Error("No match for: #{line}")
        if not results.is_full_match
          throw new Error("No full match: #{line} => #{results.compiled[0].join(" ")}#{end}")

      @eval_ed().push results.compiled

    true
  
    
    
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

word_is_now = new Procedure "Update !>WORD< to: !>ANY<."
word_is_now.write 'procedure', (match) ->
  name = _.first match.args()
  val  = _.last  match.args()
  match.env().update_data name.remove_quotes(), val
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

catch_err = ( msg, func ) ->
  err = null
  try
    func()
  catch e
    err = e
  return true if not err
  if err.message.indexOf(msg) > -1
    false
  else
    throw err

run_comparison_on_match = (op, r, l, match) ->
  known_type = catch_err "Can't convert value into type for comparison", () ->
    match.replace( compare(op, r, l) )
  if known_type
    match
  else
    match.is_a_match(false)
  
not_equals = new Procedure "!>ANY< not equal to !>ANY<"
not_equals.write 'priority', 'last'
not_equals.write 'procedure', (match) ->
  r = match.args()[0]
  l= match.args()[1]
  run_comparison_on_match("!=", r, l, match)
  
equals = new Procedure "!>ANY< equals !>ANY<"
equals.write 'priority', 'last'
equals.write 'procedure', (match) ->
  r = match.args()[0]
  l = match.args()[1]
  run_comparison_on_match("=", r, l, match)

_while_ = new Procedure "While !>ANY<:"
_while_.write 'procedure', (match) ->
  
  env = match.env()
  val = match.args()[0]
  code = match.code().text()
  tokens = null
  
  if val.is_ilu and val.is_ilu()
    val = val.remove_quotes()
    tokens = _.flatten( new englishy.Englishy(val + '.').to_tokens() )
    
  if not (tokens) and not (val in [true,false])
    match.is_a_match(false)
    return match

  re_run = (val) ->
    ans = if not ( val in [true, false] )
      bool = env.run_tokens(tokens).compiled[0]
      # console.log "--", env.data()
      if not _.isEqual( bool, [true] ) and not _.isEqual( bool, [false] )
        throw new Error("No match found: #{tokens}")
      bool[0]
    else 
      val
      
    return ans
    
  while (re_run(val))
    env.write 'loop_total', env.loop_total() + 1
    if env.loop_total() > LOOP_LIMIT
      throw new Error("Loop limit exceeded #{LOOP_LIMIT} using: While #{val}.")
    luv = new i_love_u(code, env)
    luv.run()
    # console.log luv.data()
    
  match.replace true
  match


i_love_u.add_base_proc  if_true
i_love_u.add_base_proc  if_false
i_love_u.add_base_proc  else_false
i_love_u.add_base_proc  as_num
i_love_u.add_base_proc  md_num
i_love_u.add_base_proc  word_is_word
i_love_u.add_base_proc  word_is_now
i_love_u.add_base_proc  not_equals
i_love_u.add_base_proc  equals
i_love_u.add_base_proc  _while_

