luv = require "i_love_u"
assert = require 'assert'

new_luv = (args...) ->
  new luv.i_love_u(args...)

stack = (env) ->
  arr = ( obj.value() for obj in env.data() )
  arr


describe "i_love_u", () ->
  
  describe 'constructor(str, env)', () ->

    it "sets .data() to the same object as original", () ->
      l = new_luv("One is: 1.")
      l.run()
      nl = new_luv("Two is: 2.", l)
      nl.data().push new luv.Var("Five", 5)
      
      assert.deepEqual l.data(), nl.data()

  describe 'constructor(str)', () ->

    it "sets .scope() to []", () ->
      l = new_luv("This is a new scope.")
      assert.deepEqual l.scope(), []

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
      
  describe 'update_data(k,v)', () ->

    it "updates value of given key", () ->
      u = new_luv """
        My-Var is: 1.
      """
      u.run()
      u.update_data "My-Var", 2
      assert.deepEqual stack(u), [2]

  describe 'run()', () ->
    
    it "raises an error if no sentence match", () ->
      u = new_luv """
        This does not match.
      """
      err = null
      try
        u.run()
      catch e
        err = e
      assert.equal err.message, "No match for: This does not match."

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

  describe 'run_tokens(args...)', () ->

    it "evals the tokens as if they were a parsed string.", () ->
      u = new_luv """
      One is: 1.
      """
      u.run()
      u.run_tokens(['Two', 'is:', '2'])
      assert.deepEqual stack(u), ['1','2']

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


  describe "if/else", () ->

    it "evals block if true", () ->
      u = new_luv """
      If true:
        One is: 1.
      else:
        Two is: 2.
      """
      u.run()
      assert.deepEqual stack(u), ["1"]

    it "evals 'else' block if false", ()->
      u = new_luv """
      If false:
        One is: 1.
      else:
        Two is: 2.
      """
      u.run()
      assert.deepEqual stack(u), ["2"]
      
      
  describe 'x equals y', () ->

    it "has low priority", () ->
      u = new_luv """
        Answer is: 1 + 1 + 2 equals 1 + 1 + 1 + 1.
      """
      u.run()
      assert.deepEqual stack(u), [true]
      

  describe 'while', () ->

    it "evals block until condition is false", () ->
      u = new_luv """
        Number is: 1.
        While "Number not equal to 3":
          Update "Number" to: Number + 1.
      """
      u.run()
      assert.deepEqual stack(u), [3]


      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
