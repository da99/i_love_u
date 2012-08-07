
class Sentence_Pattern

  module Module
    
    %{ 
    
      parent
      has_args
      pattern
      pattern_regexp
      replace_pattern
      replace_pattern_regexp 
    
    }.each { |name|
      
      private
      attr_writer name.to_sym
      
      public 
      attr_reader name.to_sym
      
    }
    
    
    def initialize sentence, code
      
      self.parent = sentence
      
      # === PATTERNS
      space         = '\\ {0,}'
      word          = "[^\ ]+[[:alnum:]]"
      arg_pattern   = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
      split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!
      
      # Add arguments, in their orignal order, to sentence.
      # => [ [ 'Noun', nil ] ,  [ 'Word', 'URL' ]  ]
      parent.add_arguments( code.scan(arg_pattern) )
      
      # Escape any text that is not an argument.
      # => "text\ is\ escaped\ while\ ARGS\ are\ not"
      arg_wrappers = (code).split(%r!(#{arg_pattern})!).map { |piece|
        if piece =~ arg_pattern
          Regexp.escape(piece)
        else
          piece
        end
      } 

      self.pattern                = arg_wrappers.gsub(arg_pattern, '(' + word + ')')
      self.pattern_regexp         = Regexp.new(pattern)
      self.replace_pattern        = arg_wrappers.gsub(arg_pattern, word)
      self.replace_pattern_regexp = Regexp.new(replace_pattern)

    end

  end # === module

  include Module

end # === class
