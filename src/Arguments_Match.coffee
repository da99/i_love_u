rw = require "rw_ize"
funcy_perm = require "funcy_perm"
surgeon    = require "array_surgeon"
_          = require "underscore"

class Arguments_Match

  rw.ize(this)

  @read_able "list", "env", "line", "new_line", "slice_desc", "args"
  @read_write_able_bool "is_a_match", "is_full_match", "is_for_entire_line"

  @extract_args: (match, list) ->
    start = match.slice_desc().start_index
    end   = match.slice_desc().end_index
    slice = match.slice_desc().slice
    args  = []
    
    if slice.length != list.length
      throw new Error("Slice does not match list length: #{slice.length} != #{list.length}. Check start and end positions.")
    
    for a, i in list
      if !a.is_plain_text()
        args.push slice[i]

    args

  @permutate: (env, line) ->
    line_arr = line.line()
    block    = line.block()
    # Permuatate on variables.
    data_pos = ( i for str,i in line_arr when env.is_name_of_data(str) )

    raw_perms = funcy_perm(data_pos).perm (val, i) ->
      -1

    perms = []
    for group in raw_perms
      clone = line_arr.slice(0)
      for ind in group
        if ind != -1
          clone[ind] = env.data(clone[ind], line)
      perms.push clone
    perms

  constructor: (arg_list, env, line, proc) ->

    @rw_data "list",  arg_list.list()
    @rw_data "env",  env
    @rw_data "line",  line
    @rw_data "args",  []
    
    if arg_list.is_block_required() 
      if not @line().block()
        return null
      
    f = _.first(@list())
    l = _.last( @list())
    if f.is_start()
      if l.is_end() or ( l.is_splat && l.is_splat() )
        @is_for_entire_line(true)
      
    # All possible variable matches.
    perms = if proc.priority() is "before_variables"
      [ line.line() ]
    else
      @constructor.permutate(env, line)
      
    list    = @list()
    finders = []

    print_it = false
    args = []
    
    for a, a_i in @list()
      finders.push (v, i, fi) ->
        
        arg = list[fi]
        return false unless arg
          
        if !(arg.is_splat && arg.is_splat())
          if arg.is_start()
            return false if i isnt 0

          if arg.is_end() 
            last_i = perms[0].length - 1
            return false if i isnt last_i

        extracted = arg.extract_args(v, env, line)
        
        if not extracted
          args = []
          return false 
          
        if extracted.length
          args.splice args.length, 0, extracted...
        
        true
        
      if a.is_splat and a.is_splat()
        _.last(finders).is_splat = true

    # Select combo that matches.
    pi             = 0 # pi as in perm i
    limit          = perms[0].length - finders.length 
    final_line_arr = null 
    desc_slice     = null
    
    loop

      for combo, i in perms
        args = []
        desc_slice = surgeon(combo).describe_slice(finders, pi)
        if desc_slice
          final_line_arr = combo 
          break

      if final_line_arr
        @is_a_match true
        
        # Set variable/values as args.
        @rw_data "new_line",    final_line_arr
        @rw_data "slice_desc",  desc_slice
        @rw_data "args",        args
        
        result = proc.procedure()(this)
        if @is_a_match()
          @replace(result)
        else
          final_line_arr = null
          
      pi += 1
      break if final_line_arr or (pi >= limit)
      
    

  replace: ( val ) ->
    
    i = @slice_desc().start_index
    l = @slice_desc().length
    @new_line().splice i, l, val
    @line().write 'line', @new_line()
    
    if @is_for_entire_line()
      @is_full_match(true)
      
    @line()



module.exports = Arguments_Match
