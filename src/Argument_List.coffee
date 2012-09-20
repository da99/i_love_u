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
      @rw 'is_block_required', true

    full_sentence = str.has_end_period() or str.has_end_colon()
    if full_sentence
      str = str.replace( /\.$/, "" ).replace( /\:$/, "" )
    @rw 'list', ( ( new Argument(v) ) for v in str.whitespace_split() )
    
    if full_sentence
      _.first(@list()).is_start(true)
      _.last(@list()).is_end(true)
      
module.exports = Argument_List
