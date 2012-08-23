rw = require "rw_ize"
funcy_perm = require "funcy_perm"
surgeon    = require "array_surgeon"

class Arguments_Match

  rw.ize(this)

  @read_able "list", "env", "line", "code", "line_arr", "slice_desc", "args"
  @read_write_able_bool "is_a_match"

  @extract_args: (match, list) ->
    start = match.slice_desc().start_index
    end   = match.slice_desc().end_index
    slice = match.line_arr().slice start, end
    args  = []
    if slice.length != list.length
      throw new Error("Slice does not match list length. Check start and end positions.")
    
    for a, i in list
      if !a.is_plain_text()
        args.push slice[i]

    args

  @permutate: (env, line_arr, code) ->
    # Permuatate on variables.
    data_pos = ( i for str,i in line_arr when env.is_name_of_data(str) )

    raw_perms = funcy_perm(data_pos).perm (val, i) ->
      -1

    perms = []
    for group in raw_perms
      clone = line_arr.slice(0)
      for ind in group
        if ind != -1
          clone[ind] = env.data(clone[ind])
      perms.push clone
    perms

  constructor: (arg_list, env, line_n_code) ->
    line = line_n_code[0]
    code = line_n_code[1]
    @rw_data().list = arg_list.list()
    @rw_data().env  = env
    @rw_data().line = line
    @rw_data().code = code
    @rw_data().args = []
    
    # All possible variable matches.
    perms = @constructor.permutate(env, line, code)

    # Select comb that matches.
      
    list = @list()
    find_func = (v, i) ->
      list[i] && list[i].is_a_match_with(v)

    finders = ( find_func for v in @list() )

    final_line_arr = null 
    desc_slice = null
    for combo, i in perms
      desc_slice = surgeon(combo).describe_slice(finders)
      if desc_slice
        final_line_arr = combo 
        break

    # console.log desc_slice, list[1].is_a_match_with("+") if @list()[1].user_pattern() is "!>CHAR<"
    return null unless final_line_arr
    @rw_data().is_a_match = true
      
    # Set variable/values as args.
    @rw_data().line_arr   = final_line_arr
    @rw_data().slice_desc = desc_slice
    @rw_data().args       = @constructor.extract_args(this, list)


module.exports = Arguments_Match
