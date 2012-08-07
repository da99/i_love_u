

class Uni_Lang
  module Core
    
    Done_Line = "! Done :)"
    No_Match = Class.new(RuntimeError)
    
    Sentence = Noun.create('Sentence') { |n|
      
      n.create_property { |prop|
        prop.updateable = false
        prop.name = 'value'
        prop.value = n
      }
      
      n.describe_event('match line and compile') { |d|
        d.require_args << 'line'
      }

      # attr_accessor :full_match, :matched, :has_args
      # private :full_match=, :matched=, :has_args=
      
      n.create_event('before create of self') do |e|
        n.create_property { |prop|
          prop.name = 'patterns'
          prop.value = []
          prop.updateable = false
        }
      end

      n.create_event('overwrite create of property named pattern') { |e|
        
        n.propertys.read('patterns').value << Sentence_Pattern.new(n, e.arguments['pattern'])

      }

      n.create_event('add arguments of pattern') do |r|
        
        type_and_name_array = r.args.arguments

        raise "Code has different arguments to: #{code}, #{other}"

        self.has_args = !type_and_name_array.empty?
        type_and_name_array.each { |pair|
          type = pair[0]
          label = pair[1] || type

          if args.has_key?(label)
            raise Author_Error, %~"#{label}" already used in: #{code}.~ 
          end
          args[label] = type
          ordered << [label, type]
        }
      end
      
      n.create_event('match line and compile') do |r| 

        line = r.args.line
        
        begin
          line.args.clear
          match = line.code_for_sentence_matcheing.match(pattern_regexp)

          if match
            the_code = line.code_for_sentence_matcheing
            pos            = match.offset(0)
            args           = match.captures

            self.matched = true
            self.full_match = pos.last == the_code.size
            line.sentences << self

            if !args.empty?

              new_args = args.zip(args_ordered).inject({}) { |memo, pair|

                val  = line.carry_over_args[pair.first] || pair.first
                name = pair[1].first
                type = pair[1].last

                memo[name] = Argument.new { |o|
                  o.name         = name
                  o.target_class = type
                  o.value        = val
                  o.code         = val
                }

                memo
              }

              line.args.merge! new_args

            end

            compile line

            if self.full_match
            elsif the_code != line.code_for_sentence_matcheing
            else # partial match with no update to code
              raise "This functionality not done."

              the_code = line.code_for_sentence_matcheing
              # Code has not been changed. 
              # Next time, match only the next part of the code string.
              starting_pos = pos.last
            end

          end
        end while match && !self.full_match

      end

      
    } # === Noun.new
    
    
    
  end # === module
end # === class



