

class Code_To_Array
  
  include Parser::Module
  
  def parse code_block
    lines = code_block.lines
    
    new_lines = if lines.respond_to?(:split)
                  lines.split("\n")
                else
                  lines
                end

    raise "Empty code block" if new_lines.empty? && !code_block.core
    
    new_lines
  end

end # === Code_To_Array
