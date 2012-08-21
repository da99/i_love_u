_  = require "underscore"
rw = require "rw_ize"
Argument = require "i_love_u/lib/Argument"
Arguments_Match = require "i_love_u/lib/Arguments_Match"

class Argument_List
  
  rw.ize(this)
  @read_able "list"

  
  constructor: (raw_str) ->
    str = raw_str.strip()
    full_sentence = str.has_end_period() or str.has_end_colon()
    if full_sentence
      str = str.replace( /\.$/, "" ).replace( /\:$/, "" )
    @rw_data().list = ( ( new Argument(v) ) for v in str.whitespace_split() )
    
    if full_sentence
      _.first(@list()).is_start(true)
      _.last(@list()).is_end(true)
      
  compile: (env, line_n_code) ->
    
    match = new Arguments_Match(this, env, line_n_code)
      
    # If no match, return.
    return null unless match.is_a_match()

    # Return match obj.
    match

module.exports = Argument_List
