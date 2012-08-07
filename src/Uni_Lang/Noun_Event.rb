
class Noun
  
  class Event

    module Module

      attr_accessor :name, :action

      def initialize name, &blok
        self.name = name
        self.action = blok
        raise "Name is required." unless self.name
      end

      def run args
        action.call( args )
      end

    end # === module

    include Module

  end # === class
  
end # === class Noun
