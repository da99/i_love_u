rw = require "rw_ize"
_  = require "underscore"
class Line

  rw.ize this
  @read_able "origin_line", "origin_code" 
  @read_write_able "line", "code" 

  constructor: (line, code) ->
    @rw_data "origin_line", line
    @rw_data "origin_code", code
    @write "line", line
    @write "code", code


  code_text: () ->
    @code() && @code().text()

  origin_code_text: () ->
    @origin_code() && @origin_code().text()

  is_equal_to: ( line ) ->
    _.isEqual( @line(), line.line() ) && _.isEqual( @code_text(), line.code_text() )

  has_changed: () ->
    _.isEqual( @origin_line(), @line() ) && _.isEqual( @origin_code_text(), @code_text() )

  pair: () ->
    if @code()
      [ @line(), @code() ]
    else
      [ @line() ]

  origin_pair: () ->
    if @origin_code()
      [ @origin_line(), @origin_code() ]
    else
      [ @origin_line() ]



module.exports = Line
