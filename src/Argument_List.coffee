_  = require "underscore"
rw = require "rw_ize"
Argument = require "i_love_u/lib/Argument"

class Argument_List
  
  rw.ize(this)
  @read_able "list"

  @extract_args: (match, list) ->
    start = match.slice_description.start_index
    end   = match.slice_description.end_index
    slice = match.line_arr.slice start, end
    args  = []
    if slice.length != list.length
      throw new Error("Slice does not match list length. Check start and end positions.")
    
    for a, i in list
      if !a.is_plain_text()
        args.push slice[i]

    args


  @permutate: (env, line, code) ->
    # Whitespace split
    line_arr = line.strip().whitespace_split()
    
    # Permuatate on variables.
    data_pos = ( i for str,i in line_arr when env.has_data(str) )

    raw_perms = funy_perm(data_pos).perm (val, i) ->
      -1

    perms = []
    for group in raw_perms
      clone = line_arr.clone
      for ind in group
        if ind != -1
          clone[ind] = env.data(clone[ind])
      perms.push clone
    perms
  
  constructor: (raw_str) ->
    str = raw_str.strip()
    @rw_data().list = ( ( new Argument(v) ) for v in str.whitespace_split() )
    
    if str.has_end_period() or str.has_end_colon()
      _.first(@list()).is_start(true)
      _.last(@list()).is_end(true)
      
  compile: (env, line, code) ->
    
    match = new Arguments_Match(this, env, line, code)
      
    
    # If no match, return.
    return null unless match.is_a_match()

    # Return match obj.
    match

module.exports = Argument_List
