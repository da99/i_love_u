

class Uni_Lang
  module Core

    Noun = ::Noun.new('Noun') { |n|
      
      n.create_event('in scope event describes') { |e|
        select = e.optional('select')
        name = e.require('name')
        t = e.target
        all = t.ancestor_line.map(&:event_describes).flatten + t.event_describes
        e.result = all.select { |desc| 
          desc.matches?(name) 
        }.flatten
      }
      
      n.create_event('in scope events') { |e|
        select = e.optional('select')
        list = ancestor_line.map { |anc| anc.events } + events 
        list.flatten
      }
      
      n.create_event('in scope events named') { |e|
        name = e.require('name')
        select = lambda { |n|
          n.name == name
        }
        e.result = e.target.run_event('in scope events', 'select' => select)
      }
      
    } # === Noun.new

  end # === module
end # === class
