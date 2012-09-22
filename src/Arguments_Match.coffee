rw = require "rw_ize"
funcy_perm = require "funcy_perm"
surgeon    = require "array_surgeon"
_          = require "underscore"

class Arguments_Match

  rw.ize(this)

  @read_able "list", "line", "new_line", "slice_desc", "args", "origin_args"
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

  constructor: (line, proc) ->
    if arguments.length is 1
      @rw "line", arguments[0]
      return this
    
    @rw "list",  proc.args_list().list()
    @rw "line",  line
    @rw "args",  []
    @rw "origin_args",  []
    
    if proc.args_list().is_block_required() 
      if not @line().block()
        return null
      
    f = _.first(@list())
    l = _.last( @list())
    if f.is_start()
      if l.is_end() or ( l.is_splat && l.is_splat() )
        @is_for_entire_line(true)
      
    # All possible variable matches.
    list    = @list()
    finders = []

    print_it    = false
    args        = []
    origin_args = []
    
    desc_slice     = null
    
    for a, a_i in @list()
      finders.push (v, i, fi) ->
        
        # return false unless v

        arg = list[fi]
        return false unless arg
          
        if !(arg.is_splat && arg.is_splat())
          if arg.is_start()
            return false if i isnt 0

          if arg.is_end() 
            last_i = line.line().length - 1
            return false if i isnt last_i

        extracted = arg.extract_args(v, line)
    
        if not extracted
          args = []
          origin_args = []
          return false 
          
        if extracted.length
          args.splice        args.length, 0, extracted[0]...
          origin_args.splice origin_args.length, 0, extracted[1]...
        
        true
        
      if a.is_splat and a.is_splat()
        _.last(finders).is_splat = true

    
    # ==== Scan the array until proc.procedure returns true
    i =0 
    limit = line.line().length - finders.length
    loop 
      desc_slice  = surgeon(line.line()).describe_slice(finders, i)
      
      if desc_slice
        
        @is_a_match true
        
        # Set variable/values as args.
        @rw "new_line",    line.line() 
        @rw "slice_desc",  desc_slice
        @rw "args",        args
        @rw "origin_args", origin_args
        
        result = proc.procedure()(this)
        if @is_a_match()
          @replace(result)

      i += 1
      break if i > limit or @is_a_match()
          

  replace: ( val ) ->
    
    i = @slice_desc().start_index
    l = @slice_desc().length
    @new_line().splice i, l, val
    @line().line @new_line()
    
    if @is_for_entire_line()
      @is_full_match(true)
      
    @line()



module.exports = Arguments_Match
