
class Noun
  class Event
    class Run
      
      module Module
        
        attr_accessor :name, :parent_noun, :action, :result
        attr_reader   :before, :after, :args, :arguments, :describes
        
        def initialize name, args = {}
          @arguments = args
          @name   = name
          @parent_noun = nil
          @action = nil
          @result = nil
          @before = []
          @after  = []
          yield(self)
        end
        
        def describes
          @describes ||= parent_noun.run_event('in scope event describes', 'name'=>name)
        end

        def args
          @args ||= begin
                      keys = describes.map(&:args).flatten.uniq
                      arguments = self.arguments
                      a = Class.new {
                        attr_accessor :original, :target_noun, :defined_noun *(keys + arguments.keys)
                      }.new

                      a.original = keys
                      
                      @arguments.each { |key, val|
                        a.send "#{key}=", val
                      }

                      a.target_noun = parent_noun
                      
                      a
                    end
        end
        
        def require name
          val = args.respond_to?(name) ? args.send(name) : nil
          if !val
            raise "Missing argument: #{name.inspect}"
          end
          
          val
        end

        def optional name
          return(nil) if !args.respond_to?(name)
          args.send(name)
        end

        def run
          
          required = describes.map(&:require_args).flatten.uniq
          missing = required.select { |key|
            !args.send(key)
          }
          
          if not missing.empty?
            raise "Following are required arguments: #{missing.inspect}"
          end
          
          before.each { |b|
            parent_noun.named(b).action.call(self)
          }
          
          action.call(self) if action
          
          after.each { |b|
            parent.named(b).action.call(self)
          }
          
          result
        end

      end # === module

      include Module

    end # === class Run
  end # === class Event
end # === class Noun
