
class Argument
  
  module Module
    
    attr_accessor :code, :name, :value, :target_class, :value, :parent
    
    def initialize
      yield self
      
      raise "Name is required." unless @name
      raise "Code is required." unless @code 
    end

  end # === module

  include Module

end # === class
