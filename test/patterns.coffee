luv = require "i_love_u"
Procedure    = require "i_love_u/lib/Procedure"
assert = require 'assert'

helper = require "i_love_u/lib/test/helper"
new_luv = helper.new_luv
stack   = helper.stack

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
    assert.deepEqual stack(u), [ ["this", "and", "this"] ]

