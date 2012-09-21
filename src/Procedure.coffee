rw = require "rw_ize"
Argument_List = require("i_love_u/lib/Argument_List")

class Procedure

  rw.ize(this)
  @read_write_able 'position', 'pattern', 'data', 'list', 'procedure'
  @read_able 'args_list', 'regexp'

  constructor: (pattern) ->
    @rw "data",     {}
    @rw "pattern",  pattern.strip()
    @rw "list",     []
    @rw "position", 'bottom'
    @rw "args_list", new Argument_List(@pattern())

  is_a_procedure: () ->
    true

  is_like: (str) ->
    @pattern().indexOf(str) > -1


module.exports = Procedure
