rw = require "rw_ize"
Argument_List = require("i_love_u/lib/Argument_List")

class Procedure

  rw.ize(this)
  @read_write_able 'priority', 'pattern', 'data', 'list', 'procedure'
  @read_able 'args_list', 'regexp'

  constructor: (pattern) ->
    @rw_data "data",     {}
    @rw_data "pattern",  pattern.strip()
    @rw_data "list",     []
    @rw_data "priority", 'low'
    @rw_data "args_list", new Argument_List(@pattern())

  run: ( env, line ) ->
    this.log_it = true if  @pattern().indexOf('a new') > -1
    
    match = @args_list().compile(env, line, this )
    return null if !match or !match.is_a_match()
    match

module.exports = Procedure
