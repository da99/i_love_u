parser = require 'englishy'
englishy = require 'englishy'

Array.prototype.rubyish =
  inject: (stat, func) ->
    memo = start
    for i in this
      memo = func(memo, i)
    memo
if !RegExp.escape
  RegExp.escape= (s) ->
    return s.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&')
    
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
  
  @read_write_able 'address', 'pattern', 'stack', 'procs', 'data'
  @read_able 'code', 'original_code'

  constructor: (str) ->
    @d = {}
    @d.original_code = str
    
    
    @d.original_code = str
    @d.code    = str.englishy('standardize')
    @d.procs   = [].concat this.Base_Procs
    @d.stack   = []
    @d.data    = {}
    
  run: () ->
    lines = (new englishy.Englishy @code()).to_array()
    me = this
    for pair, i in lines
      
      line = pair[0]
      code = pair[1]
      match = false
      stop  = false
      current  = line
      compiled = line
      
      while !stop
        # compiled = current
        # current = procs.inject line,  (memo, o) ->
          # o.run me, current, code

        # if compiled is current
          # if @data()
            # for k,v of @data()
              # r_txt = "(?:^|\s+)" + Regexp.escape(k) + "(?:\s+|$)"
              # current = current.replace( (new RegExp(r_txt, "g") , " #{v} ").englishy('strip')

        stop = (compiled is current)
    stack
  
exports.Procedure = class Procedure

  rw.ize(this)
  @read_write_able 'pattern', 'regexp', 'data', 'stack', 'procedure'

  word_reg: /\[\s*WORD\s*\]/g
  num_reg:  /\[\s*NUM\s*\]/g
  
  constructor: (pattern) ->
    @d = {}
    @d.data = {}
    @d.pattern = pattern
    @d.stack = []
    
    str = RegExp.escape(pattern.englishy 'strip')
    str = str.replace( @word_reg, "([a-zA-Z0-9\.\_\-]+)" )
    str = str.replace( @num_reg,  "([\+\-]?[\-0-9\.]+)"  )
    @d.regexp = new RegExp str, "g"

  run: ( env, line, code ) ->
    return line unless @regexp().test line
    @d.data["Args"]         = captures
    @d.data["Block"]        = code
    @d.data["Outer-Block"]  = env
    r= procedure(this)
    @stack().push r
    line.replace( @regexp, r.toString() )

  
add_num = new Procedure "[NUM] + [NUM]"
add_num.write 'procedure', (env) ->
  env.data()['Args'].inject 0, (m, n) ->
    m.to_f + n.to_f
      

word_is_word = new Procedure "[WORD] is [WORD]"
word_is_word.write 'procedure', (env) ->
  name = env.data()['Args'][0]
  val  = env.data()['Args'][1]
  env.data()['Outer-Block'].data()[name] = val
     

i_love_u.Base_Procs.push add_num
i_love_u.Base_Procs.push word_is_word



