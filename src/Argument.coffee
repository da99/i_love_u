rw = require "rw_ize"
_  = require "underscore"
XRegExp = require('xregexp').XRegExp
englishy = require 'englishy'
str_compare = 'englishy'.stringy_compare 
    
class Argument
  
  @types: () ->
    @_types_ ?= (this[t] for t in ['splat', 'WORD', 'NUM', 'CHAR', 'ANY', 'Noun', 'true', 'true_or_false', 'false'])
    

  @escaped_end_period: /\\\.$/
  @regexp_types_used: /\!\>([^\s]+)\</g
  @regexp_any_type: /(\!\>[^\s]+\<)/g
  
  @regexp_capture_any_type:  () ->
    @_regexp_capture_any_type_ ?=  /(!>[^<]+<)/g 
    
  @user_pattern_to_types: (txt) ->
    me = Argument.user_pattern_to_types
    if not me.map
      me.map = {}
      for t in Argument.types()
        me.map[ t.user_pattern() ] = t
    
    
    regex = null
    val = t for t in Argument.types() when t.user_pattern() is txt
    if val
      return [regex, [val]]
    
    captures = XRegExp.split( txt, Argument.regexp_capture_any_type() )
    if captures.length is 1 and captures[0] is txt
      return null

    types = []
    tokens = []
    for v in captures
      if me.map[v]
        tokens.push( "(.+)" )
        types.push me.map[v]
      else
        tokens.push XRegExp.escape(v)
        
    regex = XRegExp.globalize XRegExp( tokens.join("") )
    [ regex, types ]

  
  rw.ize(this)
  @read_able "user_pattern", "first_type", "types", "regex"
  @read_write_able_bool "is_start", "is_end"
  

  constructor: (txt) ->
    @rw_data().user_pattern = txt
    regex_and_types = Argument.user_pattern_to_types(txt)
    if regex_and_types
      @rw_data 'regex', regex_and_types[0]
      @rw_data 'types', regex_and_types[1]
      @rw_data 'first_type', @types()[0]
    @write "is_start", false
    @write "is_end",   false

  is_splat: () ->
    return false if @is_plain_text()
    ( not not @first_type().is_splat ) && @first_type().is_splat()

  extract_args: (raw_txt, env, line) ->
    if not raw_txt.value
      raw_txt = new englishy.Stringy(raw_txt)

    txt = raw_txt.value()
    ctxt = env.get_if_data(txt, line) 
    target = if raw_txt.is_quoted()
      txt
    else
      ctxt
      
    if @regex() 
      origin_args  = []
      args         = []
      mismatch     = false
      i            = -1
      captures     = RegExp.captures( @regex(), txt ) 
      
      return null unless captures
      
      for raw_s in captures
        i += 1
        s = (new englishy.Stringy(raw_s)) 
        origin_args.push   s.value()
        
        compiled_arg = if s.is_quoted()
          s.value()
        else
          env.get_if_data s.value(), line
          
        mismatch = not @types()[i].is_a_match_with( compiled_arg ) 
        break if mismatch
        args.push compiled_arg

      return null if mismatch or _.isEmpty args
      return [ args, origin_args ]
        
    else if @is_plain_text() 
      if txt is @user_pattern() or ctxt is @user_pattern()
        return true

    else if @types().length is 1
      if @first_type().is_a_match_with(target)
        return [ [target], [target] ]
    
    null

  is_plain_text: () ->
    if @first_type()
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
      
  @Noun:
    d: {}
    
    user_pattern: () ->
      @d.user_pat ?= "!>Noun<"
      
    is_a_match_with: (unk) ->
      unk.is_a_noun and unk.is_a_noun()
      
    convert: (unk) ->
      unk

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
