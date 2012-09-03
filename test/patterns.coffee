luv = require "i_love_u"
Procedure    = require "i_love_u/lib/Procedure"
assert = require 'assert'

new_luv = (args...) ->
  new luv.i_love_u(args...)

stack = (env) ->
  arr = ( obj.value() for obj in env.data() )
  arr

describe "pattern: !>...<", () ->

  it "accepts tokens until end of line: Do !>...<:", () ->
    u = new_luv """
      Record this and this:
        Blank.
    """
    pr = new Procedure "Record !>...<:"
    pr.write 'procedure', (match) ->
      match.env().add_data("tokens", match.args())
      match.replace true
      
    u.procs().push pr
    u.run()
    assert.deepEqual stack(u), [ [["this", "and", "this"]] ]

