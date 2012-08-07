

class Noun
  
  module Module

    attr_reader :name, :propertys, :events, :event_describes, :ancestor_nouns
    attr_accessor :importable, :parent_code_block

    def initialize name = :default, *ancestors
      @events          = []
      @event_describes = []
      @ancestor_nouns  = ancestors
      @importable      = false
      @propertys       = {}
      @name            = (name == :default) ? nil : name
      @parent_code_block = nil 
      
      if ancestors.empty?
        describe_event "create a property" do |d|
          d.require_args << 'property'
          d.require_args << 'name'
          d.require_action = true
        end
      end

      yield(self)
      raise "Name is required." unless self.name
    end

    def create name, *ancestors, &blok
      ancs = [self] + ancestors
      Noun.new(name, *ancs, &blok)
    end

    def ancestor_line
      ancestor_nouns.map { |n|
        [n.ancestor_nouns, n]
      }.flatten.uniq
    end

    def valid? str, program
      program.nouns.detect { |noun|
        noun.name == str && noun.ancestors.include?(name)
      }
    end

    def inspect_informally
      "#{name} (#{self.class.name}) - #{propertys.map { |pair| pair.first.to_s + ': ' + pair.last.value.to_s }.join(', ') }"
    end

    # === Events =========================================
    
    def create_event event_name, &blok
      events << Event.new(event_name, &blok) 
    end

    def describe_event name, &blok
      this = self
      
      if block_given?
        @event_describes << ::Noun::Event::Describe.new(name) { |d|
          d.parent_noun = this
          d.instance_eval( &blok )
        }
      else
        targets = in_scope('event describes', name)

        ::Noun::Event::Describe.new(name){ |d|
          d.parent_noun = this
          d.consume *targets
        }
      end
      
    end

    def events_named target
      events.select { |e|
        case target
        when String
          e.name == target
        else
          e.name =~ target
        end
      }
    end

    def run_event name, args = {}, &blok

      this = self
      e_run = ::Noun::Event::Run.new(name, args) { |r|
        r.parent_noun = this
        blok.call(r) if blok
      }

      result    = nil
      overwrite = "overwrite #{name}"
      before    = "before #{name}"
      after     = "after #{name}"

      methods   = run_event('in scope events named', 'name'=>name)

      ow_event  = run_event('in scope events named', 'name'=>overwrite).last
      b_events  = run_event('in scope events named', 'name'=>before)
      a_events  = in_scope('events named', after)

      return( ow_event.run( name, &blok ) ) if ow_event

      b_events.each { |ev|
        ev.run args
      }

      result = e_run.run

      a_events.each { |ev|
        ev.run args
      }

      result
    end
    
    
    # === Propertys ======================================
    
    def create_property &blok
      new_prop = ::Noun::Property.new(&blok) 
      name = new_prop.name
      raise "Property, #{name}, already created." if propertys.has_key?(name)

      this = self
      
      run_event("create a property") { |r|
        r.args.name = name
        r.args.property = new_prop 
        r.action = lambda  do |ir|
          this.propertys[name] = new_prop
        end
      }
    end
    
    def immutable_property name, val
      create_property { |p|
        p.name       = name
        p.updateable = false
        p.value      = val
      }
    end

    def property_named name
      raise "Property does not exist: #{name}" unless property_exists?(name)
      propertys[name] 
    end
    
  end # === module

  include Module
  
end # === class Noun
