

class Noun_Number

  include Noun::Module
  
  def data_type?
    true
  end
  
  def valid? str, program
    pos = ( str =~ /\d+(\.\d+)?/ )
    return false if pos == nil
    true
  end

end # === class Noun_Word
