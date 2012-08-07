# == Classes 
classes = %w{ 
  
  Parser 
  Line 
  Argument

  Noun 

  Noun_Event
  Noun_Event_Describe
  Noun_Event_Run

  Noun_Property
  
}

classes.each { |name|
  require "Uni_Lang/#{name}"
}


# == Parsers

parsers = %w{ 
  Code_To_Array
  Code_Array_To_Lines
  Code_Ignore_Empty_Lines
  Code_To_Code_Block
}

parsers.each { |name|
  require "Uni_Lang/Parser/#{name}"
}


  
# == Nouns
nouns = %w{
  Noun
  Sentence
  Code_Block
  Code_Block_Alias
  Code_Block_Import
}

nouns.each { |name|
  require "Uni_Lang/Noun/#{name}"
}


# == Sentences
sentences = %w{
  Noun_Create
  Noun_Set_Property
  Property_Of_Noun
  Import_As
  Page_Is_Importable
}
sentences.each { |name|
  require "Uni_Lang/Sentence/#{name}"
}

class Uni_Lang
  module Core
    
    Core = Code_Block.create('Core Code Block') { |o|
      o.parent_code_block = o
      o.immutable_property('core', true)
    }
    
    
  end # === module
end # === class

(nouns + sentences).each { |name|
  Uni_Lang::Core::Core.run_event( 'insert noun', 'noun' => eval("Uni_Lang::Core::#{name}") )
}

parsers.each { |name|
  Uni_Lang::Core::Core.run_event( 'insert parser', 'parser' => eval(name) ) 
}


__END__


