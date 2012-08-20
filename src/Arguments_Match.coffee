rw = require "rw_ize"

class Arguments_Match

  rw.ize(this)

  @read_able "list", "env", "line", "code", "line_arr", "slice_desc", "args"
  @read_write_able_bool "is_a_match"

  constructor: (list, env, line, code) ->
    @rw_data().list = list
    @rw_data().env  = env
    @rw_data().line = line
    @rw_data().code = code
    @rw_data().args = []
    
    # All possible variable matches.
    perms = Argument_List.permutate(env, line, code)

    # Select comb that matches.
    finders = ( v.is_a_match_with for v in @list() )
    final_line_arr = null 
    desc_slice = null
    for combo, i in perms
      desc_slice = surgeon(combo).describe_slice(finders)
      if desc_slice
        final_line_arr = combo 
        break

    return null unless final_line_arr
    @rw_data().is_a_match = true
      
    # Set variable/values as args.
    @rw_data().line_arr   = final_line_arr
    @rw_data().slice_desc = desc_slice
    @rw_data().args       = Argument_List.extract_args(match)


module.exports = Arguments_Match
