
class Parser
  
  Invalid_Space_Formatting = Class.new(RuntimeError)
  Invalid_Code_Block_Placement = Class.new(RuntimeError)
  
  module Module
    
    def self.included klass
      klass.extend Class_Methods
    end

    def initialize 
      @code_block = nil
      yield(self) if block_given?
    end
    
    module Class_Methods
      
      def parse code_block
        new.parse code_block
      end

    end

  end # === module 
  
  include Module

end # === class 
