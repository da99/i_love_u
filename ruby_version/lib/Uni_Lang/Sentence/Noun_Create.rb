

class Uni_Lang
  module Core
    
    Noun_Create = Sentence.create('Sentence-Noun-Create') { |o|
      
      o.importable = true
      
      o.create_property { |prop|
        prop.name       = 'pattern'
        prop.value      = "[Word] is a [Noun]."
        prop.updateable = false
      }
      
      o.create_event('compile') do |e|
        line       = e.args.line
        name       = line.args['Word'].value
        ancestor   = line.args['Noun'].value
        parent     = line.parent.parent
        importable = parent.is_a?(Page) && parent.importable

        line.parent.create_noun(name) { |n|
          n.ancestors << ancestor
          n.importable = importable
        }
      end
      
    }
    
  end # === Core
end # === class

