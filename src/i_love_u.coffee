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
    

    
exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'list', 'procs', 'data'
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

  constructor: (str) ->
    @rw_data().original_code = str
    
    @rw_data().code =  str.standardize()
    @write 'procs' , [].concat(@constructor.Base_Procs)
    @write 'list'  , []
    
  add_to_data: (k, v) ->
    obj = 
      name: k
      value: v
      inherits_from: []

    @list().push obj

  add_to_list: (val) ->
    @list().push val

  is_name_of_data: (k) ->
    val = v for v in @list() when v.name == k
    return true if val
    false

  data: ( k ) ->
    if k
      val = v for v in @list when v.name is k
      val.value
    else
      vals = (v for v in @list() when v.hasOwnProperty("name") and v.hasOwnProperty("value") )

  run: () ->
    lines = (new englishy.Englishy @code()).to_array()
    me = this
    @compile_sentence_func ?= (memo, proc) ->
      proc.run me, memo
      
    for line_and_block, i in lines
      
      line       = line_and_block[0]
      code_block = line_and_block[1]

      if line and !code_block
        line = line.remove_end('.')
      else if line and code_block
        line = line.remove_end(':')
        
      line     = line.whitespace_split()
      current  = [ line, code_block ]
      compiled = null
      matched = true
      
      while matched
        compiled = _.reduce( @procs(), @compile_sentence_func, current )
        matched = !(_.isEqual(compiled, current))
        current = compiled
        
    @list()
  
    
    
md_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
md_num.write 'priority', 'high'
md_num.write 'procedure', (env) ->
  m = env.data()['Args'][1]
  op= env.data()['Args'][2]
  n = env.data()['Args'][3]
  switch op
    when '*'
      parseFloat(m) * parseFloat(n)
    when '/'
      parseFloat(m) / parseFloat(n)
    else
      ignore_this: true

as_num = new Procedure "!>NUM< !>CHAR< !>NUM<"
as_num.write 'procedure', (env) ->
  m = env.data()['Args'][1]
  op= env.data()['Args'][2]
  n = env.data()['Args'][3]
  switch op
    when '+'
      parseFloat(m) + parseFloat(n)
    when '-'
      parseFloat(m) - parseFloat(n)
    else
      ignore_this: true

  
word_is_word = new Procedure "!>WORD< is: !>WORD<."
word_is_word.write 'procedure', (env) ->
  pair = env.data()['Args']
  name = pair[1]
  val  = pair[2]
  env.data()['Outer-Block'].add_to_data name, val
  val
     

i_love_u.add_base_proc  as_num
i_love_u.add_base_proc  md_num
i_love_u.add_base_proc  word_is_word


