_  = require "underscore"
rw = require "rw_ize"
Argument = require "i_love_u/lib/Argument"
Arguments_Match = require "i_love_u/lib/Arguments_Match"

class Argument_List
  
  rw.ize(this)
  @read_able "list"
  @read_able_bool "is_block_required"

  
  constructor: (raw_str) ->
    str = raw_str.strip()
    
    if str.has_end_colon()
      @rw_data().is_block_required = true

    full_sentence = str.has_end_period() or str.has_end_colon()
    if full_sentence
      str = str.replace( /\.$/, "" ).replace( /\:$/, "" )
    @rw_data().list = ( ( new Argument(v) ) for v in str.whitespace_split() )
    
    if full_sentence
      _.first(@list()).is_start(true)
      _.last(@list()).is_end(true)
      
  compile: (env, line, proc) ->
    match = new Arguments_Match(this, env, line, proc)
    return null unless match.is_a_match()
    match

module.exports = Argument_List
