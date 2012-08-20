rw = require "rw_ize"
Argument_List = require("i_love_u/lib/Argument_List")

class Procedure

  rw.ize(this)
  @read_write_able 'priority', 'pattern', 'data', 'list', 'procedure'
  @read_able 'args', 'regexp'

  constructor: (pattern) ->
    @rw_data().data = {}
    @rw_data().pattern = pattern
    @rw_data().list = []
    @rw_data().priority = 'low'
    
    @rw_data().args = new Argument_List pattern.strip()

  run: ( env, line_n_code ) ->
    match = @args().compile(env, line_n_code)
    return line_n_code if !match.is_a_match
    r = @procedure()(match)
    [r.line, r.code]

module.exports = Procedure
