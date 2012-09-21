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
    
to_noun = (n) ->
  n.is_a_noun = () ->
    true
    
  n.add_user_method = (name, meth) ->
    this["user_method_#{name}"] = meth
    
  n.is_user_method = (name) ->
    not not this["user_method_#{name}"]
    
  n.call_user_method = (name, args...) ->
    this["user_method_#{name}"](args...)

  n

is_boolean_string = (v) ->
  v in [ 'true', 'false']
  
boolean_type_cast = (v) ->
  
  if not is_boolean_string(v)
    throw new Error("Can't be converted to boolean: #{v}")
  
  if v is "true"
    true
  else 
    false
 
comparison_type_cast = (v) ->
  v = if _.isString(v)
    if v is is_boolean_string(v)
      boolean_type_cast(v)
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
    when "==="
      r is l
    when "!=="
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
  

# Add basic Nouns:
    
    
md_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
md_num.position  'top'
md_num.procedure (match) ->
  m = match.args()[0]
  op= match.args()[1]
  n = match.args()[2]
  switch op
    when '*'
      parseFloat(m) * parseFloat(n)
    when '/'
      parseFloat(m) / parseFloat(n)
    else
      match.is_a_match(false)
  

as_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
as_num.procedure  (match) ->
  m = match.args()[0]
  op= match.args()[1]
  n = match.args()[2]
  switch op
    when '+'
      parseFloat(m) + parseFloat(n)
    when '-'
      parseFloat(m) - parseFloat(n)
    else
      match.is_a_match false
      
  
word_is_word = new Procedure "!>WORD< is: !>ANY<."
word_is_word.procedure  (match) ->
  name = _.first match.args() 
  val  = _.last  match.args()
  match.env().add_data name, val
  val

clone_list = new Procedure "a clone of !>List<"
clone_list.position "top"
clone_list.procedure  (match) ->
  list = _.first match.args()
  env  = match.env()
  $.extend(true, {}, clone)

derive_list = new Procedure "a derivative of !>List<"
derive_list.position  "top"
derive_list.procedure (match) ->
  list = _.first match.args()
  env  = match.env()
  new list()



update_word = new Procedure "Update !>WORD< to: !>ANY<."
update_word.procedure  (match) ->
  name = _.first match.args()
  val  = _.last  match.args()
  match.env().update_data name, val
  val
     
if_true = new Procedure "If !>true_or_false<:"
if_true.procedure (match) ->
  raw_val = match.args()[0]
  return match.is_a_match(false) unless is_boolean_string(raw_val)
  
  ans = boolean_type_cast(raw_val)
  if ans is true
    luv = new i_love_u match.line().block(), match.env()
    luv.run()
    
  match.env().scope().push ans
  ans
    

else_false = new Procedure "else:"
else_false.procedure  (match) ->
  if _.last(match.env().scope()) is false
    luv = new i_love_u(match.line().block(), match.env())
    luv.run()
    false
  else
    true

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
  val = null
  
  known_type = catch_err "Can't convert value into type for comparison", () ->
    val = compare(op, r, l)
    
  if known_type
    val
  else
    match.is_a_match(false)
  
not_equals = new Procedure "!>ANY< not equal to !>ANY<"
not_equals.position 'bottom'
not_equals.procedure (match) ->
  r = match.args()[0]
  l= match.args()[1]
  run_comparison_on_match("!==", r, l, match)
  
equals = new Procedure "!>ANY< equals !>ANY<"
equals.position 'bottom'
equals.procedure (match) ->
  r = match.args()[0]
  l = match.args()[1]
  run_comparison_on_match("===", r, l, match)

_do_ = new Procedure "Do:"
_do_.procedure  (match) ->
  block = match.line().block()
  env  = match.env()

  luv = new i_love_u(block, env)
  luv.run()
  match.env().scope().push { from_do: true, block: block }
  true

while_loop = new Procedure "While !>true_or_false<."
while_loop.procedure (match) ->
  env  = match.env()
  prev = _.last(env.scope()) 
  ans  = match.args()[0]

  block = if prev and prev.from_do
    prev.block
  else
    match.line().block() 
    
  return match.is_a_match(false) if !block
    
  if ans
    env.record_loop( match.line().origin_line_text() )
    (new i_love_u(block, env)).run()
    env.run_tokens match.line().origin_line(), block 
    
  env.scope().push ans
  ans
  
a_new_noun = new Procedure "a new !>Noun<"
a_new_noun.procedure  (match) ->
  env  = match.env()
  noun = match.args()[0]
  cloneextend.clone(noun)

prop_of_noun = new Procedure "the !>WORD< of !>WORD<"
prop_of_noun.procedure  (match) ->
  env = match.env()
  method = match.args()[0]
  noun_name = match.args()[1]
  
  if not env.is_name_of_data(noun_name)
    return match.is_a_match(false)
  noun = env.data(noun_name)
  
  if not noun.is_a_noun?()
    return match.is_a_match(false)

  if not noun.is_user_method(method)
    return match.is_a_match(false)

  noun.call_user_method(method)



insert_into_list = new Procedure "Insert at the !>WORD< of !>Noun<: !>ANY<."
insert_into_list.procedure (match) ->
  env = match.env()
  pos  = match.args()[0]
  list = match.args()[1]
  val  = match.args()[2]
  
  if not list.insert or not (pos in ['top', 'bottom'])
    return match.is_a_match(false)
  else
    list.insert pos, val
    val

top_bottom = new Procedure "!>Noun<, from top to bottom as !>WORD<:"
top_bottom.procedure  (match) ->

  noun     = match.args()[0]
  pos_name = match.args()[1]
  block    = match.line().block()
  env      = match.env()
  
  pos      = noun.target().position()
  to_noun(pos)
  pos.add_user_method "value", () ->
    this.value()

  env.add_data( pos_name, pos )
  
  if pos.is_at_bottom()
    return false

  loop
    (new i_love_u block, env ).run()
    break if pos.is_at_bottom()
    pos.downward()
    
  true
  
  


i_love_u.add_base_proc  if_true
i_love_u.add_base_proc  else_false
i_love_u.add_base_proc  as_num
i_love_u.add_base_proc  md_num

i_love_u.add_base_proc  word_is_word
i_love_u.add_base_proc  update_word

i_love_u.add_base_proc  clone_list
i_love_u.add_base_proc  derive_list

i_love_u.add_base_proc  not_equals
i_love_u.add_base_proc  equals
i_love_u.add_base_proc  while_loop
i_love_u.add_base_proc  _do_
i_love_u.add_base_proc  a_new_noun
i_love_u.add_base_proc  prop_of_noun
i_love_u.add_base_proc  insert_into_list
i_love_u.add_base_proc  top_bottom

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



