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
    while (match = r.exec(str))
      vals ?= []
      vals.push match
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
    me.on_prototype = "write".split(/\s+/)
    me.on_class = "read_able write_able read_write_able".split(/\s+/)
    me.funcs = 
      read_write_able: (args...) ->
        @read_able(args...)
        @write_able(args...)
        
      read_able: (args...) ->
        for prop in args
          this.prototype[prop] = () ->
            @d[arguments.callee.prop_name]
          this.prototype[prop].prop_name = prop
          
      write_able:  (args...) ->
        for prop in args
          this.prototype.write_ables ?= []
          this.prototype.write_ables.push prop

      write: (prop, val) ->
        if !(prop in this['write_ables'])
          throw new Error("#{prop} is not write_able.")
        @d[prop] = val

  for m in me.on_prototype
    klass.prototype[m] = me.funcs[m]
    
  for m in me.on_class
    klass[m] = me.funcs[m]

exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  rw.ize(this)
  
  @read_write_able 'address', 'pattern', 'list', 'procs', 'data'
  @read_able 'code', 'original_code'

  constructor: (str) ->
    @d = {}
    @d.original_code = str
    
    
    @d.original_code = str
    @d.code    = str.englishy('standardize')
    @d.procs   = [].concat(@constructor.Base_Procs)
    @d.list    = []
    
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
  @read_write_able 'pattern', 'regexp', 'data', 'list', 'procedure'

  word_reg: /\\\[\s*WORD\s*\\\]/g
  num_reg:  /\\\[\s*NUM\s*\\\]/g
  escaped_end_period: /\\\.$/
  
  constructor: (pattern) ->
    @d = {}
    @d.data = {}
    @d.pattern = pattern
    @d.list = []
    
    str = RegExp.escape(pattern.englishy 'strip')
    str = str.replace( @word_reg, "([a-zA-Z0-9\.\_\-]+)" )
    str = str.replace( @num_reg,  "([\+\-]?[\-0-9\.]+)"  )
    if @escaped_end_period.test str
      str = "^" + str.replace( @escaped_end_period, "" ) + "$"
    @d.regexp = new RegExp str, "g"

  run: ( env, line, code ) ->
    captures = RegExp.first_capture(@regexp(), line)
    return line unless captures
    @d.data["Args"]         = captures
    @d.data["Block"]        = code
    @d.data["Outer-Block"]  = env
    r = @procedure()(this)
    l = line.replace( captures[0], r.toString() )
    l

  
add_num = new Procedure "[NUM] + [NUM]"
add_num.write 'procedure', (env) ->
  m = env.data()['Args'][1]
  n = env.data()['Args'][2]
  val = parseFloat(m) + parseFloat(n)
  val
      

word_is_word = new Procedure "[WORD] is: [WORD]."
word_is_word.write 'procedure', (env) ->
  pair = env.data()['Args']
  name = pair[1]
  val  = pair[2]
  env.data()['Outer-Block'].add_to_data name, val
  val
     

i_love_u.Base_Procs.push add_num
i_love_u.Base_Procs.push word_is_word



