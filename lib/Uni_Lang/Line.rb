

class Line 

  module Module

    attr_reader :number, :code_block, :sentences, :args, :carry_over_args, :skip
    attr_accessor :parent, :index, :code, :ignore, :code_for_sentence_matcheing

    def initialize
      @ignore    = false
      @sentences = []
      @args      = {}
      @carry_over_args = {}
      @skip      = 1
      
      yield self

      if !@parent
        raise "No parent stated."
      end

      if !@index
        raise "No index stated. This is the array index of lines in code block."
      end
      
      if !@code
        raise "No text provided for line."
      end
      
      self.code_for_sentence_matcheing = self.code
      
      @number    = @index + 1
      
    end

    def empty?
      code.strip.empty?
    end

    def matched?
      not sentences.empty?
    end

    def full_match?
      sentences.detect { |sent| sent.full_match }
    end

    def partial_match?
      matched? && !full_match?
    end

    def skip_next num
      @skip += num
    end

    def add_to_code_block str
      @code_block_code ||= []
      @code_block_code << str.sub(/\A  /,'')
    end

  end # === module

  include Module

end # === class Line
