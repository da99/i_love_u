parser = require 'englishy'
englishy = require 'englishy'

Property_ize = (proto) ->
  me = arguments.callee
  
  if !me.read_able
    me.read_able = (args...) ->
      for prop in args
        this[prop] = () ->
          @d[arguments.callee.prop_name]
        this[prop].prop_name = prop
        
    me.write_able = (args...) ->
      for prop in args
        @d ?= {}
        @d['writers'] ?= []
        @d['writers'].push prop

    me.write = (prop, val) ->
      if !(prop in @d['writers'])
        throw new Error("#{prop} is not allowed to be updated.")
      @d[prop] = val

    me.read_write_able = (args...) ->
      @read_able(args...)
      @write_able(args...)
      
    me.methods = "read_able write_able write read_write_able".split(/\s+/)
  
  for m in me.methods
    proto[m] = me[m]
   

exports.i_love_u = class i_love_u
  
  @No_Match = "no_match"
  @Base_Procs = []

  # attr_accessor :address, :pattern, :stack, :procs, :data
  # attr_reader   :code

  # for prop in "address pattern stack procs data code".split( /\s+/ )
    # eval """
      # #{this}.prototype.#{prop} = function() {
        # return this.d.#{prop};
      # };
    # """
      
  Property_ize(this.prototype)

  constructor: (str) ->
    @d = {}
    @d.original_code = str
    @read_write_able 'address', 'pattern', 'stack', 'procs', 'data'
    @read_able 'code', 'original_code'
    
    
    @d.original_code = str
    @d.code    = str.englishy('standardize')
    @d.procs   = this.Base_Procs + []
    @d.stack   = []
    
  
  parse: () ->
    @d.tree = new englishy.Englishy @code()

  # def run
    
    # this = self
    # lines = parse( code )

    # lines.each_with_index { |pair, i|
      
      # line, code = pair
      # match = false
      # stop  = false
      # current  = line
      # compiled = line
      
      # while !stop do
        # compiled = current
        # current = procs.inject(line) { |memo, o|
          # o.run self, current, code
        # }

        # if compiled == current
          # data.each { |k,v|
            # current = current.gsub( %r!(\A|\s+)#{Regexp.escape k}(\s+|\Z)! , " #{v} ").strip
          # }
        # end

        # stop = compiled == current
      # end

    # }

    # stack
  
exports.Procedure = class Procedure

  Property_ize(this.prototype)

  constructor: (pattern) ->
    @d = {}
    @d.data = {}
    @read_write_able 'pattern', 'regexp', 'data', 'stack', 'procedure'
    @d.pattern = pattern
    str = Regexp.escape(pattern.strip)
    str = str.gsub(%r"\\\[\s*WORD\s*\\\]", "([a-zA-Z0-9\.\_\-]+)")
    str = str.gsub(%r"\\\[\s*NUM\s*\\\]",  "([\+\-]?[\-0-9\.]+)")
    @d.regexp = Regexp.new str

  run: ( env, line, code ) ->
    return line unless @regexp().test line
    @d.data["Args"]         = $~.captures
    @d.data["Block"]        = code
    @d.data["Outer-Block"]  =  env
    r= procedure(this)
    end.stack.push r
    line.replace(regexp, r.toString() )

  
# i_love_u::Base_Procs << i_love_u::Procedure.new("[NUM] + [NUM]") { |o|
  # o.procedure = lambda { |env|
    # env.data['Args'].inject(0) { |m, n|
      # m.to_f + n.to_f
      # 

# i_love_u::Base_Procs << i_love_u::Procedure.new("[WORD] is [WORD]") { |o|
  # o.procedure = lambda { |env|
    # name, val = env.data['Args']
    # env.data['Outer-Block'].data[name] = val
     
   



