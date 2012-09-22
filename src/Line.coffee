rw = require "rw_ize"
_  = require "underscore"
class Line

  rw.ize this
  @read_able "origin_line", "origin_block", "calling_env"
  @read_write_able "line", "block"

  constructor: (line_and_block, env) ->
    if not env
      throw new Error "Calling env. of line is required."
    line = line_and_block[0]
    block = line_and_block[1]
    @rw "origin_line",  line.slice(0)
    @rw "origin_block", block
    @rw "calling_env",  env
    @line    @origin_line()
    @block   @origin_block()


  is_a_line: () ->
    true

  origin_line_text: () ->
    new_arr = []
    for v in @origin_line()
      new_arr.push if v.value
        "#{v.value()}"
      else
        "#{v}"
    new_arr.join " "

  block_text: () ->
    @block() && @block().text()

  origin_block_text: () ->
    @origin_block() && @origin_block().text()

  is_equal_to: ( line ) ->
    _.isEqual( @line(), line.line() ) && _.isEqual( @block_text(), line.block_text() )

  has_changed: () ->
    same_line  = _.isEqual @origin_line(), @line() 
    same_block = _.isEqual @origin_block_text(), @block_text()  
    not same_line or not same_block

  pair: () ->
    if @block()
      [ @line(), @block() ]
    else
      [ @line() ]

  origin_pair: () ->
    if @origin_block()
      [ @origin_line(), @origin_block() ]
    else
      [ @origin_line() ]



module.exports = Line
