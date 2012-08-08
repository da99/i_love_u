luv = require "i_love_u"
assert = require 'assert'

new_luv = (str) ->
  new luv.i_love_u(str)

describe "i_love_u", () ->
  
  describe 'constructor()', () ->

    it "sets .code() to working copy of code.", () ->
      l = new_luv("This is code.")
      assert.equal l.code(), "This is code."

    it "sets .original_code() to working copy of code.", () ->
      l = new_luv("This is origin.")
      assert.equal l.original_code(), "This is origin."

    it "sets .stack() to []", () ->
      l = new_luv("This starts a stack.")
      assert.deepEqual l.d.stack, []

    it ".address is write_able", () ->
      l = new_luv("This is code.")
      l.write 'address', "/some.address/"
      assert.equal l.address(), "/some.address/"
      
  # it "saves values to stack", () ->
    # u = new_luv """
      # Val is 1
      # Val + 5
    # """
    # u.run()
    # assert.deepEqual u.stack(), ["1", 6.0]

  # it "runs", () ->
    # prog  = """
      # Superhero is a Noun.
      # Rocket-Man is a Superhero.
      # The real-name of Rocket-Man is Bob.
      # The real-job of Rocket-Man is marriage-counselor.
      # The real-home of Rocket-Man is "Boise, ID".
        # #{' ' * 3}
        # I am something.
        # I am another thing.

      # Import page, /banzai/characters, as CONTENT.
      # The second-home of Rocket-Man is the real-home of Rocket-Man.
      # The second-job of Rocket-Man is the real-job of Rocket-Man.

    # """

    # u =  new_luv prog
    # u.run()
    # assert.deepEqual u.stack(), ["Super"]




