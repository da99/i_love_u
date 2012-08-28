luv = require "i_love_u"
assert = require 'assert'

new_luv = (str) ->
  new luv.i_love_u(str)

stack = (env) ->
  arr = ( obj.value() for obj in env.data() )
  arr


describe "i_love_u", () ->
  
  describe 'constructor()', () ->

    it "sets .code() to working copy of code.", () ->
      l = new_luv("This is code.")
      assert.equal l.code(), "This is code."

    it "sets .original_code() to working copy of code.", () ->
      l = new_luv("This is origin.")
      assert.equal l.original_code(), "This is origin."

    it "sets .data() to []", () ->
      l = new_luv("This starts a data list.")
      assert.deepEqual l.data(), []

    it ".address is write_able", () ->
      l = new_luv("This is code.")
      l.write 'address', "/some.address/"
      assert.equal l.address(), "/some.address/"
      
  describe 'run()', () ->
    
    it "saves values to data", () ->
      u = new_luv """
        One is: 1.
        Six is: One + 5.
      """
      u.run()
      assert.deepEqual stack(u), ["1", 6.0]

    it "runs partial sentences based on priority", () ->
      u = new_luv """
        One is: 1.
        Thirty_Two is: 5 / 5 + One - 3 * -10.
      """
      u.run()
      assert.deepEqual stack(u), ["1", 32]

  describe 'special variables for manipulating the block attached to line', () ->

    it "sets Block_Text_Line_N to Nth text line of block", () ->
      str = " I am a \"crazy' string\", ok\"."
      u = new_luv """
        Str is: Block_Text_Line_3:
          
          I am the first string.
          I am the second string.
          #{str}
          I am the fourth string.
            
      """

      u.run()
      assert.deepEqual stack(u), [str]

    it "sets Block_List_N to Nth text line as list", () ->
      u = new_luv """
        Var is: Block_List_2:
          1 1 1 1
          
          2 2 2 2
      """

      u.run()
      assert.deepEqual stack(u), ["2 2 2 2".whitespace_split()]

    it "sets Block_List_N to Nth text line as list of tokens", () ->
      u = new_luv """
        Var is: Block_List_2:
          "one 1" "two 1" "three 1" "four 1"
          
          "one 2" "two 2" "three 2" "four 2"
      """

      u.run()
      assert.deepEqual stack(u), [['"one 2"', '"two 2"', '"three 2"', '"four 2"']]


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
    # assert.deepEqual u.data(), ["Super"]
      
      
      
