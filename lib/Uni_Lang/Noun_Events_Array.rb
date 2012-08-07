
class Noun
  class Events_Array < Array

    module Module

      attr_reader :describes
      attr_accessor :parent

      def initialize noun
        @parent = noun
        @describes = []
        super()
      end

      def describe name = nil, &blok
        this = self
        
        if block_given?
          @describes << ::Noun::Event::Describe.new(name) { |d|
            d.parent = this
            d.instance_eval( &blok )
          }
        else
          raise "Name is required." unless name
          
          targets = in_scope('something')
          
          ::Noun::Event::Describe.new(name){ |d|
            d.parent = this
            d.consume *targets
          }
        end
      end

      def create event_name, &blok
        self << Event.new(event_name, &blok) 
      end

      def named target
        select { |e|
          case target
          when String
            e.name == target
          else
            e.name =~ target
          end
        }
      end

      def run event_name, &blok

        this = self
        e_run = ::Noun::Event::Run.new(event_name) { |r|
          r.parent = this
          r.instance_eval { blok.call(r) }
        }
        
        result = nil
        methods   = named(event_name)
        overwrite = "overwrite #{event_name}"
        before    = "before #{event_name}"
        after     = "after #{event_name}"

        ow_event = methods.detect { |m| m.name == overwrite }
        b_events  = methods.select { |m| m.name == before }
        a_events  = methods.select { |m| m.name == after }

        return ow_event.run( args ) if ow_event

        b_events.each { |ev|
          ev.run args
        }

        result = e_run.run

        a_events.each { |ev|
          ev.run args
        }

        result
      end

    end # === module
    
    include Module

  end # === class
end # === class Noun
