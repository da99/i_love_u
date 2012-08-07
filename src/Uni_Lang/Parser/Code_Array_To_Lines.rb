

class Code_Array_To_Lines
  
  include Parser::Module

  def parse code_block

    lines = code_block.lines
    
    new_lines  = []
    
    raise "Empty code block." if lines.empty? && !code_block.core

    total = lines.size
    index = -1
    
    while index < total-1
      index += 1
      
      line          = lines[index]
      previous_line = new_lines.last
      spaces        = line[/\A\ +/]
      even_spaces   = spaces && (spaces.size % 2).zero?
      empty         = line.strip.empty?
      
      if (!previous_line && empty) ||  # this line is first and empty
        (previous_line && previous_line.empty?) ||  # this line is second and empty
        (!spaces && !empty)
        
        new = if line.is_a?(String)
                Line.new { |o|
                  o.index = index
                  o.code = line
                  o.parent = code_block
                }
              else
                line
              end
        new_lines << new
        
        next
        
      end


      if !even_spaces && !empty
        raise Parser::Invalid_Space_Formatting, "Uneven number of spaces: line #{index}: #{line}"
      end
      
      if !previous_line
        raise Parser::Invalid_Code_Block_Placement, "Code block has no parent: line #{index}: #{line}"
      end
      
      previous_line.add_to_code_block line
      
    end
    
    new_lines
  end

end # === Code_Array_To_Lines
