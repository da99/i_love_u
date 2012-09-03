rw = require "rw_ize"

class Argument
  @types: () ->
    @_types_ ?= (this[t] for t in ['splat', 'WORD', 'NUM', 'CHAR', 'ANY', 'true', 'true_or_false', 'false'])
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

  is_splat: () ->
    return false if @is_plain_text()
    ( not not @type().is_splat ) && @type().is_splat()

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

  @splat: 
    
    is_splat: () ->
      true

    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>...<"
      
    is_a_match_with: (arr) ->
      arr.length isnt 0
      
    convert: (unk) ->
      unk

  @ANY:
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>ANY<"
        
    is_a_match_with: (unk) ->
      return false if "#{unk}".is_whitespace()
      true
      
    convert: (unk) ->
      unk
      
  @true:
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>true<"
      
    is_a_match_with: (unk) ->
      "#{unk}" is "true" 
      
    convert: (unk) ->
      true
      
  @false:
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>false<"
      
    is_a_match_with: (unk) ->
      "#{unk}" is "false"
      
    convert: (unk) ->
      false
      
  @true_or_false:
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>true_or_false<"
      
    is_a_match_with: (unk) ->
      "#{unk}" is "true" || "#{unk}" is "false"
      
    convert: (unk) ->
      return true if unk is "true"
      false
      
  @WORD: 
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>WORD<"
      
    is_a_match_with: (unk) ->
      return false if !unk.is_whitespace 
      return false if unk.is_whitespace()
      !unk.is_whitespace()
      
    convert: (unk) ->
      unk.strip()
      
  @NUM:
    d: {}
    user_pattern: () ->
      @d.user_pat ?= "!>NUM<"

    is_a_match_with: (unk) ->
      !isNaN( parseFloat(unk) )

    convert: (unk) ->
      parseFloat(unk)
      
  @CHAR:
    d: {}
    user_pattern: () ->
      @d.user_path ?= "!>CHAR<"

    is_a_match_with: (unk) ->
      return false if !unk.strip
      unk.strip().length == 1
      
    convert: (unk) ->
      unk.strip()


module.exports = Argument
