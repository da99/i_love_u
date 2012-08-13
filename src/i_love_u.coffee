parser = require 'englishy'
englishy = require 'englishy'

if !Array.prototype.inject
  Array.prototype.inject = (start, func) ->
    memo = start
    for i in this
      memo = func(memo, i)
    memo
    
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
    
rw = {}
rw.ize = (klass) ->
  me = arguments.callee
  if !me.read_able
    me.on_prototype = ["write", "d"]
    me.on_class = ["read_able", "write_able", "read_write_able"]
    me.funcs = 
      read_write_able: (args...) ->
        @read_able(args...)
        @write_able(args...)
        
      d: () ->
        @__d ?= {}

      read_able: (args...) ->
        for prop in args
          this.prototype[prop] = () ->
            @d()[arguments.callee.prop_name]
          this.prototype[prop].prop_name = prop
          
      write_able:  (args...) ->
        for prop in args
          this.prototype.write_ables ?= []
          this.prototype.write_ables.push prop

      write: (prop, val) ->
        if !(prop in this['write_ables'])
          throw new Error("#{prop} is not write_able.")
        @d()[prop] = val

  for m in me.on_prototype
    klass.prototype[m] = me.funcs[m]
    
  for m in me.on_class
    klass[m] = me.funcs[m]


exports.Args = class Args
  @types: ['WORD', 'NUM', 'CHAR']
  @escaped_end_period: /\\\.$/
  @regexp_types_used: /\!\>([^\s]+)\</g
  
  rw.ize(this)
  @read_write_able "types", "regexp"
  constructor: (raw_str) ->
    @write 'types', (v[1] for v in RegExp.captures( Args.regexp_types_used, raw_str ))
      
    str = RegExp.escape(raw_str)
    for t in Args.types
      str = str.replace( Args[t].user_pattern(), Args[t].regexp_string() )
    if Args.escaped_end_period.test str
      str = "^" + str.replace( Args.escaped_end_period, "" ) + "$"
      
    @write 'regexp', (new RegExp str, "g")

  sentence_match: (sent) ->
    caps = RegExp.captures( @regexp(), sent )
    return false if !caps or caps.length is 0

    
  @WORD: 
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= new RegExp("!>WORD<", "g")
      
    regexp_string: () ->
      @d.reg_str ?= "([a-zA-Z0-9\.\_\-]+)"
        
    is: (unk) ->
      return false if !unk.englishy 
      !unk.englishy('is_whitespace')
      
    convert: (unk) ->
      unk.englishy('strip')
      
  @NUM:
    d: {}
    user_pattern: () ->
      @d.user_pat ?= new RegExp("!>NUM<", 'g')

    regexp_string: () ->
      @regexp_string_data ?= "([\-]?[0-9\.]+)"
      
    is: (unk) ->
      parseFloat(unk) != NaN

    convert: (unk) ->
      parseFloat(unk)
      
  @CHAR:
    d: {}
    user_pattern: () ->
      @d.user_path ?= new RegExp("!>CHAR<", 'g')

    regexp_string: () ->
      @regexp_string_data ?= "([^\s])"
      
    is: (unk) ->
      unk.englishy('strip').length == 1
      
    convert: (unk) ->
      unk.englishy('strip')


exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'list', 'procs', 'data'
  @read_able 'code', 'original_code'

  constructor: (str) ->
    @d().original_code = str
    
    @d().code =  str.englishy('standardize')
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

  data: ( k ) ->
    if k
      val = v for v in @list when v.name is k
      val.value
    else
      vals = (v for v in @list() when v.hasOwnProperty("name") and v.hasOwnProperty("value") )
    
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

  run: () ->
    lines = (new englishy.Englishy @code()).to_array()
    me = this
    for pair, i in lines
      
      line = pair[0]
      code_block = pair[1]

      if line and !code_block
        line = line.englishy('remove_end', 'period')
      else if line and code_block
        line = line.englishy('remove_end', 'colon')
        
      match = false
      stop  = false
      current  = line
      compiled = line
      
      while !stop
        compiled = current
        
        for v in @data()
          r_txt = "(?:^|\\s+)" + RegExp.escape(v.name) + "(?:\\s+|$)"
          regexp = (new RegExp r_txt, "g")
          current = current.replace( regexp, " #{v.value} ").englishy('strip')
          
        current = @procs().inject current,  (memo, o) ->
          o.run me, memo, code_block

        stop = (compiled is current)
        
    @list()
  
exports.Procedure = class Procedure

  rw.ize(this)
  @read_write_able 'priority', 'pattern', 'regexp', 'data', 'list', 'procedure'

  constructor: (pattern) ->
    @d().data = {}
    @d().pattern = pattern
    @d().list = []
    @d().priority = 'low'
    
    args_meta = new Args(pattern.englishy('strip'))
    @d().regexp = args_meta.regexp()

  run: ( env, line, code ) ->
    captures = RegExp.first_capture(@regexp(), line)
    return line unless captures
    @d().data["Args"]         = captures
    @d().data["Block"]        = code
    @d().data["Outer-Block"]  = env
    r = @procedure()(this)
    return line if r and r.ignore_this
    l = line.replace( captures[0], r.toString() )
    l

  
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


