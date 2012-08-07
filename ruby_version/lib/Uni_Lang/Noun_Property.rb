

class Noun
  class Property
    
    module Module

      attr_accessor :name, :value, :updateable

      def initialize 
        @updateable = false
        @value = nil
        yield(self)
        raise "Name not set." unless @name
      end
      
      def update val
        raise "Property can not be updated: #{name}" unless updateable
        @value = val
      end
      
    end # === module

    include Module
    
  end # === class
end # === class Noun
