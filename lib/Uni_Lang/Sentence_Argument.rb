
class Sentence_Argument

  module Module
    
    attr_accessor :name, :type
    
    def initialize 
      yield self
      
      %w{ name type }.each { |attr|
        raise "#{attr.capitalize} is required." unless send(attr)
      }
    end

  end # === module

  include Module

end # === class
