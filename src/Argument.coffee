rw = require "rw_ize"

class Argument
  @type_names: ['WORD', 'NUM', 'CHAR']
  @types: () ->
    @_types_ = (this[t] for t in this.type_names)
  @escaped_end_period: /\\\.$/
  @regexp_types_used: /\!\>([^\s]+)\</g
  @regexp_any_type: /\!\>[^\s]+\</g
  @user_pattern_to_type: (txt) ->
    val = t for t in Argument.types() when t.user_pattern() is txt
    val
  
  rw.ize(this)
  @read_able "user_pattern", "type"
  @read_write_able_bool "is_start", "is_end"
  

  constructor: (txt) ->
    @rw_data().user_pattern = txt
    @rw_data().type         = Argument.user_pattern_to_type(txt)
    @write "is_start", false
    @write "is_end",   false

  is_a_match_with: (txt) ->
      
    if @is_plain_text()
      txt is @user_pattern()
    else
      @type().is_a_match_with(txt)

  is_plain_text: () ->
    if @type()
      false
    else
      true

  @WORD: 
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>WORD<"
      
    regexp_string: () ->
      @d.reg_str ?= "([a-zA-Z0-9\\.\\_\\-]+)"
        
    is_a_match_with: (unk) ->
      return false if unk.is_whitespace()
      !unk.is_whitespace()
      
    convert: (unk) ->
      unk.strip()
      
  @NUM:
    d: {}
    user_pattern: () ->
      @d.user_pat ?= "!>NUM<"

    regexp_string: () ->
      @regexp_string_data ?= "([\\-]?[0-9\\.]+)"
      
    is_a_match_with: (unk) ->
      parseFloat(unk) 

    convert: (unk) ->
      parseFloat(unk)
      
  @CHAR:
    d: {}
    user_pattern: () ->
      @d.user_path ?= "!>CHAR<"

    regexp_string: () ->
      @regexp_string_data ?= "([^\\s])"
      
    is_a_match_with: (unk) ->
      unk.strip().length == 1
      
    convert: (unk) ->
      unk.strip()


module.exports = Argument
