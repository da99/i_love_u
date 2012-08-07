

class Page

  GET_VAL = :_get_

  class << self

    def parse str_or_array
      case str_or_array
      when Array
        str_or_array
      when String
        str = str_or_array
        str.split("\n").reject { |sub| sub.strip.empty? }
      else
        raise "Unknown class: #{str_or_array.inspect}"
      end
    end

  end # === class << self

  module Module
    
    attr_reader :position, :backtrace, :code_block
    attr_accessor :file_address, :name, :code, :parent, :importer
    attr_accessor :code, :importable

    def initialize 
      @importable = false
      @backtrace  = []
      
      yield(self)
      @name       ||= "_unknown_ #{rand}"
      @code_block = Code_Block.new { |o|
        o.parent = self 
        o.code   = code 
      }
    end

    def importable?
      !!@importable
    end
    
    def is_importable
      @importable = true
    end
    
    def inspect_informally
      "Page - file address: #{file_address}"
    end

  end # === module

  include Module

end # === class
