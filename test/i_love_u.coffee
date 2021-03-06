luv = require "i_love_u"
assert = require 'assert'
limit = 10123

helper = require "i_love_u/lib/test/helper"
Var    = require "i_love_u/lib/Var"
Line   = require "i_love_u/lib/Line"
new_luv = helper.new_luv
stack   = helper.stack

describe "i_love_u", () ->
  
  describe 'constructor(str, env)', () ->

    it "sets outside env if a env is pass to it.", () ->
      l = new_luv("One is: 1.")
      l.run()
      nl = new_luv("Two is: 2.", l)
      nl.run()
      nl.vars().push (mess) ->
        mess.name "Five"
        mess.value 5
      
      assert.deepEqual stack(nl), ['1', '2', 5]

  describe 'constructor(str)', () ->

    it "sets .code() to working copy of code.", () ->
      l = new_luv("This is code.")
      assert.equal l.code(), "This is code."

    it "sets .original_code() to working copy of code.", () ->
      l = new_luv("This is origin.")
      assert.equal l.original_code(), "This is origin."

    it "sets List as a basic noun.", () ->
      l = new_luv("This starts a data list.")
      assert.deepEqual l.get('List').value().is_a_noun(), true 

    it ".address is write_able", () ->
      l = new_luv("This is code.")
      l.address "/some.address/"
      assert.equal l.address(), "/some.address/"
      
  describe 'update(k,v)', () ->

    it "updates value of given key", () ->
      u = new_luv """
        My-Var is: 1.
      """
      u.run()
      u.update_name_and_value "My-Var", 2
      assert.deepEqual stack(u), [2]

  describe 'delete(k)', () ->

    it "removes value from data list", () ->
      u = new_luv """
        One is: 1.
        Two is: 2.
        Three is: 3.
        Four is: 4.
        Five is: 5.
      """
      u.run()
      u.delete "Four"
      assert.deepEqual stack(u), ['1','2', '3', '5']

    it "raises error if data does not exist", () ->
      u = new_luv """
        My-Var is: 3.
      """
      u.run()
      err = try
        u.delete "My-Vars"
      catch e
        e
      assert.equal err.message, "Data does not exist: My-Vars."

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

  describe 'run_line_tokens(args...)', () ->

    it "evals the tokens as if they were a parsed string.", () ->
      u = new_luv """
      One is: 1.
      """
      u.run()
      u.run_line_tokens( [ ['Two', 'is:', '2'] ])
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
      assert.deepEqual stack(u), [['one 2', 'two 2', 'three 2', 'four 2']]


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
        While Number not equal to 3:
          Update "Number" to: Number + 1.
      """
      u.run()
      assert.deepEqual stack(u), [3]

    it "does not run past #{limit} total loops", () ->
      u = new_luv """
        Number is: 1.
        While Number not equal to 3:
          Update "Number" to: Number + 1.
      """
      u.loop_total( limit - 1 )
      err = try
        u.run()
      catch e
        e
      assert.equal err.message, "Loop limit exceeded #{limit} using: While Number not equal to 3."

  describe "do/while", () ->

    it "evals block until condition is false", () ->
      u = new_luv """
        Number is: 1.
        Do:
          Update "Number" to: Number + 1.
        While Number not equal to 4.
      """
      u.run()
      assert.deepEqual stack(u), [4]


  describe "!>Noun<, from top to bottom as x:", () ->

    it "creates x as a variable", () ->
      u = new_luv """
        My-List is: a new List.
        Insert at the top of My-List: 1.
        Insert at the top of My-List: 2.
        Insert at the top of My-List: 3.
        Nums is: a new List.
        My-List, from top to bottom as x-pos: 
          Insert at the top of Nums: the value of "x-pos".
      """
      u.run()
      vals = [ u.data('My-List').values(), u.data('Nums').values() ]
      assert.deepEqual vals, [['3','2','1'], ['1','2','3']]

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
