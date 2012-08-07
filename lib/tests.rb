# Code Block (aka page, applet, doc, document, object, Oberon module, etc.)
#   
# Noun
#   - Sentence
#   - Code Block
#     - file address
#     - line number
#   - Code Block Import
#     - value: Code Block
#   - Code Block Alias
#     - value: Code Block
# Line
#   - address
#   - filename
#   
# Modules: 
#   Sentence
#   Noun
#   Parser

# ========================================================


When line is partially matched against all sentences.

New Sentence: Import page as [Word Name]: [Word Address]
  should generate regexp pattern: " /Import\ page\ as\ ([^ ]+):\ ([^ ]+)\/ "
    
Only one noun can be created with the same name.
Nouns found in other scope are visible if importable is set to true.

Sentence is matched AND compiled, even if it has no arguments.

Sentences matched when defined dynamically.

Sentences are matched regardless of whitespace:
  "The property    of Something."
Sentences are matched by pattern AND data-type.
Sentences are matched by pattern AND data-type WHEN using partial sentences( "prop" of "noun")

Sentences re-matched when partially matched.
  Second match is to match entire line.
  Example: The value of Name of Scope.
  Match 1: Name of Scope
  Match 2: The value of "Match 1".
    
Multiple partials:
  Name of Scope of Page of Uni
  
Defining a sentence that takes 1 or more code blocks as arguments in the
  sentence text, with one of them called "Code Block", but it also
  accepts a code block after the sentence.

Match sentences with whitespace at the end.
Match lines with whitespace at the end.

A partial where it matches a word right before a period:
  The value of something of Something.

This line must match entirely, leaving only a value on the stack:
  value of Something of Something-Bigger.

Line must compile to various sentences that is matches.
  Right now its possible a full match might be skipped:
    full sentence
    partial sentence
    full sentence
  Also, check to see every sentence that matches is run just once.


Downsides of Uni Lang
  * makes people think computers can think
  * makes people use Regular English instead of a sub-set of English.
  * makes programming look easy.
    This is not programming. 
    It's pattern matching and algorythms
      with a little natural talent.
      If you don't play with legos as 
      an adult, you have no business programming.
      Exceptions: physicists.
      
      

* No creation of objects except by self.
  Namespacing which allows scalable dev.

* Special require for non-self requires.
  Require url() for Importer.
  Alias-Name as url() found in Importer.

* Exportable sentences and client-sentences.
  Visible: Importer, Importee.

* This-Server-Page, The-Client.
  Visible on all code blocks.

* Require takes in a block.
  Author has to specify actions for imported code.
  Imported code does not assume a certain object is created.
  
* Functionality is added through events + exported sentences.
  Bugs are avoided through namespacing + Noun Visible=False.

* Nouns: Maps + Events = All features you could ever want - Factor 

* Simple Ruby Objects for messages (aka events.)  
  Hash used to store state and functionality.

* Validation and Permissions ENTIRELY done by the site.
  No reason for user to set up their own validation/permission
  system.
    
* Authorization: Permissions manage by site.
  Authentication: Standard practices.
  EVAL: No eval possible. Everything is a string that is treated as a key/id.
  Data sent to criminal: data can't be sent outside of user permission system.
    JS AJAX: all calls are sent within site url and user urls. No custom urls allowed.
    No HTML/CSS/JS allowed.
  JS in CSS: CSS is scrubbed and validated. No JS allowed.
  Rating system for code.
    Flagged code is de-activated.
    User hierarchy for marking code as insecure or criminal.
  Security is handled at site level (aka Uni Lang).
    Must assume no one listens and does the right thing.
    Tests and certification is not enough.
  Some parts of the site are not editable: 
    Permission granting system to code and urls.
    Records involving permission code, urls, etc.
    
    


Record is from the Database:
  
  The id is: 42.
  The table-name is: CDs.
  Grab fields: title, intro.

The-Page is a Client-Page.

Viewable to all code blocks:
  * Record
  * The-Page
  * Client

On end of this code block:

  Respond to Client with The-Page.
  
The title of The-Page is:

  title of Record.

In The-Page, Intro is a Paragraph:

  intro of Record.

Create Random on data-map of The-Page:
  
  Hans Hoppe is fun.
  
On mouse click on Intro:

  Alert: title of The-Page.
  Alert: Random of data-map of The-Page.
  Update border-right of Intro of The-Page to: 2px solid red.
  

  
Uni_Lang for JavaScript
- Definitions on top only
- KV Map for server/client communication.
- JS simple objects for now only.
  UL obj sys. on server only. Can be used for
  validation.
- basic ops for server apply to client: adding, comparison , setting
- noun references: server to client
- Nouns/Sentences have different representations:

  HTML
  JavaScript
  
  Example: 
    Sun-creation is a Paragraph.
    On click of Sun-creation:
      Alert: word-count of Sun-creation.
      
    ==>
  
    Define client property, word-count, on Noun as function:
      Text is the text of Noun.
      Words is the split of text on empty space.
      Return count of Words.
      
    Define client sentence:
      Alert: {val}
      Send('alert', val);

    n = Paragraph.create('Sun-creation').
    n.on_event('js on-click') { |e|
      Client.alert(n.read_property('word-count'))
    }
    
      ==>
      <p id="Sun-creation">Some text.</p>
      <script>
        // Require jquery.
        $('Sun-creation').onclick(function(){
          window.alert( $('Sun-creation').property('inner-text').to_s.split(' ').size()  );
        });
      </script>


Uni_Lang::Core::Core.event_as_property('find_file') { |e|
  importables[e.args.address]
}

------------------------------------------------------------------

  forward an event to value of Noun
    run_event('compile line') -> noun.value.run_event...
   ----------------   
  n.run_event('match line to sentence') { |e|
    e.args['line']         = line
    e.args['file_address'] = line
  }

   ----------------   
program = Page.new { |o|
  
  o.file_address = __FILE__
  o.name         = 'main'
  o.code         = PROGRAM
  o.parent       = core
    
}

program.code_block.find_file = lambda { |address, code_block|
  importables[address]
}
program.code_block.run
pp program.code_block.nouns.map(&:inspect_informally)
print program.backtrace.to_yaml, "\n"


module Askable
  
  def askable
    @askable ||= {}
  end

  def set name, val
    raise "Already set: #{name.inspect}" if askable.has_key?(name)
    update_or_set name, val
  end

  def ask name
    raise "Key not found: #{name.inspect}" if not askable.has_key?(name)
    askable[name]  
  end

  def get name
    ask name
  end

  def update name, val
    ask name
    update_or_set name, val
  end

  def update_or_set name, val
    askable[name] = val
  end

end # === module Askable

TODO:
  * property of Noun => (partial sentence)
  * Sentence definition.
  * Passing outer, local, etc. scopes.
  * HTML/CSS/JS converters.


BASE_ACTIONS = %~

  Set prop to: this_value.
  if
  unless
    ensure
  +, -, *, /, etc.

~

%~
  
Web-Page is a Noun.
Insert Web-Page into the Importer-Page.

Paragraph is a Noun.

Quick-Paragraph is a Sentence.
A pattern for Quick-Paragraph:
  
  Paragraph:

Quick-Paragraph requires a code block.
Quick-Paragraph does:

  P is a new Paragraph.
  The text for P is the code-block of Calling-Line.
  Insert P into the Web-Page of Calling-Page.






Alias pattern



Paragraph:

  This is a paragraph.
  This continues the paragraph.

Quote:
  
  This is a block quote.
  This is a block quote continued.

Quote:

  This is a quote within a quote.

Paragraph:

  This is a new paragraph.

  This is another paragraph.


~


importables = {
  'CONTENT' => %~
This page is importable.
  ~
}
  
  
