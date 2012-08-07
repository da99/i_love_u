
class Noun
  class Event
    class Describe
      
      module Module
        
        attr_reader :name, :before, :after, :require_args, :optional_args
        attr_accessor :parent_noun, :require_action

        def initialize name = nil
          @parent_noun    = nil
          @name           = name
          @before         = []
          @after          = []
          @require_args   = []
          @optional_args  = []
          @require_action = false
          yield(self)
        end
        
        def args
          optional_args + require_args
        end
        
        def matches? str_or_regex
          case str_or_regex
          when String
            name == str_or_regex ||
              str_or_regex =~ name_as_regexp
          else
            (name =~ str_or_regex)
          end
        end
        
        def name_as_regexp
          @name_as_regexp = begin
                              word = ['[word]', '[^\ ]+']
                              esc = Regexp.escape(name).
                                gsub(Regexp.escape(word.first), word.last)
                              
                              Regexp.new(esc)
                            end
        end
        
        def consume describes
        end

      end # === module

      include Module

    end # === class Describe
  end # === class Event
end # === class Noun
