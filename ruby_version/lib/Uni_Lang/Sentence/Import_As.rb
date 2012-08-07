


class Uni_Lang
  module Core
    
    Import_As = Sentence.create('Sentence-Import-As') { |o|
      
      o.importable = true
      
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "Import page as [Word Name]: [Word Address]"
        prop.updateable = false
      }
      
      o.create_event('compile') do |run|
        line    = run.line
        name    = line.args['Name'].value
        address = line.args['Address'].value
        line.parent.import address, name
      end
      
    }
    

  end #=== module
end # === class
