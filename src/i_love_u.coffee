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
  
  @read_write_able 'address', 'pattern', 'data', 'procs', 'data'
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
    @_data_ = []
    
  add_to_data: (k, v) ->
    obj = 
      name: k
      value: v
      inherits_from: []

    @_data_.push obj

  add_to_list: (val) ->
    @_data_.push val

        
  @dynamic_data: (args...) ->
    if args.length is 0
      @_dynamic_data_
    else if args.length is 1
      name = args[0]
      func = v for k,v of @constructor._dynamic_data_ when name is k or k.test(name)
      func
    else if args.length is 2
      @_dynamic_data_ ?= []
      @_dynamic_data_.push args[0], args[1]
    else
      throw new Error("Unknown args: #{args}")
    
  @dynamic_data /^Block_Text_Line_[0-9]+$/, (env, line, block, name) ->
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      val = block.text_line( num )
      new Var(name, val)

  dynamic_data: (line, block, name) ->
    func = @constructor.dynamic_data(name)[1]
    func( this, line, block, name )
          
  @is_name_of_dynamic_data: (name) ->
    (not not @dynamic_data(name))

  is_name_of_data: (k) ->
    return true if @constructor.is_name_of_dynamic_data(k)
    
    val = v for v in @_data_ when v.name == k
    not not val

  data: ( k ) ->
    if k
      val = v for v in @_data_ when v.name is k
      val.value
    else
      vals = (v for v in @_data_ when ("name" of v) and ("value" of v) )
      vals

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
  match.env().add_to_data name, val
  match.replace val
  match
     

i_love_u.add_base_proc  as_num
i_love_u.add_base_proc  md_num
i_love_u.add_base_proc  word_is_word


