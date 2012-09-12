rw = require "rw_ize"
_  = require "underscore"
class Line

  rw.ize this
  @read_able "origin_line", "origin_block" 
  @read_write_able "line", "block" 

  constructor: (line, block) ->
    @rw_data "origin_line", line
    @rw_data "origin_block", block
    @write "line", line
    @write "block", block


  block_text: () ->
    @block() && @block().text()

  origin_block_text: () ->
    @origin_block() && @origin_block().text()

  is_equal_to: ( line ) ->
    _.isEqual( @line(), line.line() ) && _.isEqual( @block_text(), line.block_text() )

  has_changed: () ->
    _.isEqual( @origin_line(), @line() ) && _.isEqual( @origin_block_text(), @block_text() )

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
