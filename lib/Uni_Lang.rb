require 'Uni_Lang/version'
require 'Split_Lines'
require 'indentation'
require 'Walt'

class Uni_Lang
  
  No_Match = :no_match

  attr_accessor :address, :pattern, :stack, :procs, :data
  attr_reader   :code

  Base_Procs = []

  def initialize code
    @address = nil
    @author  = nil
    @pattern = nil
    @code    = standardize(code)
    @procs   = Base_Procs + []
    @stack   = []
    @data    = Hash[]
    yield self if block_given?
  end # === def initialize
  
  def standardize str
    raise ArgumentError, "No tabs allowed." if str["\t"]
    str.reset_indentation
  end
  
  def parse str
    Walt str
  end

  def run
    
    this = self
    lines = parse( code )

    lines.each_with_index { |pair, i|
      
      line, code = pair
      match = false
      stop  = false
      current  = line
      compiled = line
      
      while !stop do
        compiled = current
        current = procs.inject(line) { |memo, o|
          o.run self, current, code
        }

        if compiled == current
          data.each { |k,v|
            current = current.gsub( %r!(\A|\s+)#{Regexp.escape k}(\s+|\Z)! , " #{v} ").strip
          }
        end

        stop = compiled == current
      end

    }

    stack
  end
  
  class Procedure

    attr_accessor :pattern, :regexp, :data, :stack, :procedure
    
    def initialize pattern
      @pattern = pattern
      @data    = Hash[]
      @regexp = begin
                 str = Regexp.escape(pattern.strip)
                 .gsub(%r"\\\[\s*WORD\s*\\\]", "([a-zA-Z0-9\.\_\-]+)")
                 .gsub(%r"\\\[\s*NUM\s*\\\]",  "([\+\-]?[\-0-9\.]+)")
        
                 Regexp.new str
               end
      @procedure = nil
      yield self
    end

    def run env, line, code
      return line unless line =~ regexp
      data["Args"]         = $~.captures
      data["Block"]        = code
      data["Outer-Block"]  =  env
      r= procedure.call(self)
      env.stack << r
      line.sub(regexp, r.to_s)
    end

  end # === Meth
  
end # === class Uni_Lang


Uni_Lang::Base_Procs << Uni_Lang::Procedure.new("[NUM] + [NUM]") { |o|
  o.procedure = lambda { |env|
    env.data['Args'].inject(0) { |m, n|
      m.to_f + n.to_f
    }
  }
}

Uni_Lang::Base_Procs << Uni_Lang::Procedure.new("[WORD] is [WORD]") { |o|
  o.procedure = lambda { |env|
    name, val = env.data['Args']
    env.data['Outer-Block'].data[name] = val
  }
}
