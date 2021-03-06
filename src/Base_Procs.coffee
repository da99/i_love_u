Procedure  = require 'i_love_u/lib/Procedure'
cloneextend  = require "cloneextend"
_            = require 'underscore'
i_love_u     = null 

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
  match.line().calling_env().write().push (mess) ->
    mess.name  name
    mess.value val
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
  match.env().update_name_and_value name, val
  val
     
if_true = new Procedure "If !>true_or_false<:"
if_true.procedure (match) ->
  raw_val = match.args()[0]
  return match.is_a_match(false) unless is_boolean_string(raw_val)
  
  ans = boolean_type_cast(raw_val)
  if ans is true
    luv = new i_love_u match.line().block(), match.env()
    luv.run()
    
  match.env().push(  Var.new_local "last-if-value", ans )
  ans
    

else_false = new Procedure "else:"
else_false.procedure  (match) ->
  if match.env().get_or_throw('last-if-value').value() is false
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
  v = new Var
  b = 
  match.env().push( Var.new_local "last-do-value", true )
  match.env().push( Var.new_local "last-do-block", block)
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
    env.run_line_tokens [ match.line().origin_line(), block ]
    
  env.update_or_push( Var.new_local "last-while-loop", ans )
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
  
  



procs = {}
procs.i_love_u = (ilu) ->
  
  ilu.vars().push_name_and_value 'if_true',    if_true
  ilu.vars().push_name_and_value 'else_false', else_false
  ilu.vars().push_name_and_value 'as_num', as_num
  ilu.vars().push_name_and_value 'md_num', md_num

  ilu.vars().push_name_and_value 'word_is_word', word_is_word
  ilu.vars().push_name_and_value 'update_word',  update_word

  ilu.vars().push_name_and_value 'clone_list',  clone_list
  ilu.vars().push_name_and_value 'derive_list', derive_list

  ilu.vars().push_name_and_value 'not_equals', not_equals
  ilu.vars().push_name_and_value 'equals',     equals
  ilu.vars().push_name_and_value 'while_loop', while_loop
  ilu.vars().push_name_and_value '_do_',       _do_
  ilu.vars().push_name_and_value 'a_new_noun', a_new_noun
  ilu.vars().push_name_and_value 'prop_of_noun', prop_of_noun
  ilu.vars().push_name_and_value 'insert_into_list', insert_into_list
  ilu.vars().push_name_and_value 'top_bottom', top_bottom
  
  
module.exports = procs

