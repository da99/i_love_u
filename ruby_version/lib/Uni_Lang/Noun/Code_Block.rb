
class Uni_Lang
  module Core
    
    # How to create a core code block:
    #    Describe event: 'find file'
    Code_Block = Noun.create('Code Block'){ |n|

      n.create_event('before create of self') do |e|
        
        e.target.create_property { |prop|
          prop.name       = 'nouns'
          prop.value      = []
          prop.updateable = false
        }
        
        e.target.create_property { |p|
          p.name       = 'parsers'
          p.value      = []
          p.updateable = false
        }
        
        e.target.create_property { |p|
          p.name = 'core?'
          p.value = false
          p.updateable = true
        }

        e.target.create_property('sentences') do |p|
          p.name        = 'sentences'
          p.as_function = true
          p.value       = lambda { |e|
            e.target.read_property('nouns').select { |noun|
              noun.ancestors.include?('Sentence') || noun.ancestors.include?('Code Block')
            }
          }
        end
        
      end # === before create of self
      
      n.create_event('after create of self') do |e|
        
        
        if not e.target.ask('core?')
          e.target.read_property('nouns') << ::Uni_Lang::Core::Core
          e.target.read_property('parsers') << ::Uni_Lang::Core::Core
        end
        
      end

      n.create_event('run') do |e|
        if e.target.ask('core?') && !e.target.has?('code')
          raise 'Code is required.'
        end
      end

      # -------------------------------------------
      n.describe_event('in scope noun named') do |d|
        d.require_args << 'name'
      end

      n.create_event('in scope noun named') do |e|
        target = nil
        name = e.args.name
        n.read_property('nouns').each { |noun|
          target = if noun.has_event?('as Code Block')
                    noun.run_event('as Code Block') do |e|
                      e.args.method = :read_property
                      e.args.args << 'in scope noun named'
                      e.args.block = lambda { |run|
                        run.name = name
                      }
                    end
                   else
                     noun.name == name ?
                       noun : nil
                   end
          break if target
        }
        
        e.result = target
      end
      
      # -------------------------------------------
      n.create_event('in scope nouns') do |e|
        
        name = e.require('name')
        select = e.optional('select')
        e.result = n.read_property('nouns').map { |noun|
          
          if noun.has_event?('as Code Block')
            noun.run_event('as Code Block') do |ee|
              ee.args.method = :read_property
              ee.args.args << 'in scope nouns'
              ee.args.block = lambda { |run|
                run.args.select = select
              }
            end
          else
            select && !select.call(noun) ? nil : noun
          end
          
        }.flatten.compact
      end

      # -------------------------------------------
      n.create_event('find file') do |e|
        address = e.require('address')
        finder = n.read_property('find file function')
        if !finder
          raise "File finder function not set."
        end
        
        e.result = finder.call(e.args)
      end
      
      # -------------------------------------------
      n.create_event('match line to sentences and compile') do |e|
        line = e.require('line')
        sentences.each { |scope|

          if scope.has_ancestor?('Sentence')

            sentence = scope
            sentence.events.run('match line and compile') { |r|
              r.args.line = line
            }

          elsif scope.has_event?('as Code Block')

            scope.match_line_to_sentences_and_compile line

          else

            raise "Unknown sentence class: #{scope.inspect}"

          end

          if line.full_match?
            break
          end

        }

      end
      
      # -------------------------------------------
      n.create_event('parse') do |e|
        target = e.optional('target')

        if target === :none
          @lines = @code
          return( parse( self ) ) 
        end

        raise "No parsers specified." if parsers.empty?

        parsers.each { |plugin|

          target.lines = if plugin.respond_to?(:parse)
                           plugin.parse( target )
                         elsif plugin.respond_to?(:code_block)
                           plugin.code_block.parse( target )
                         else
                           raise "Unknown class for parser plugin: #{plugin.inspect}"
                         end

        }

        target.lines
      end

      # -------------------------------------------
      n.create_event('run') do |e|

        # === Parse code.
        parse

        # === Execute lines.
        index   = 0
        this    = self
        results = []

        while index < @lines.size

          line  = @lines[index]

          unless line.ignore

            match_line_to_sentences_and_compile(line)

            if line.partial_match?
              raise "Did not completely match: #{line.number}: #{line.code}"
            end

            if not line.matched?
              raise "Did not match: #{line.code}"
            end

          end


          index += line.skip

        end

        # scope.backtrace << "#{match.sentence.name}: #{match.args.inspect}\n#{line}\n#{sentence.code_block.code}"
      end

      
      
      # -------------------------------------------
      n.create_event('import') do |e|
        file_address = e.require('file_address')
        name_alias   = e.require('name_alias')
        
        find_file = self.find_file
        raise "Find file function not found." unless find_file
        content     = find_file.call file_address, self
        raise "File not found: #{file_address} (#{name_alias})" unless content
        this        = self

        new_page = Page.new { |o|

          o.file_address = file_address
          o.name         = name_alias
          o.parent       = this
          o.code         = content

        }

        new_page.code_block.run
        raise "Not importable: #{file_address}" unless new_page.importable?

        sentences << new_page
        nouns << new_page
        imports << new_page
        parsers << new_page
        
      end

      
    } # --- noun create

  end # === module

end # === class



