
The Building Blocks of i\_love\_u writings.
-------------------------------------------

* Numbers.
* Strings: These are also code blocks to be parsed and executed.
* The Humane List: a combination of Array and Hash. 
* Values (aka variables, objects):
  * a Humane List with required keys: value, acts\_like
  * There are no "parent classes". This is prototype classes
  using the "acts\_like" key to lookup properties.
  * Methods are properties with strings of code.
* i\_love\_u files: a collection of all other building blocks.

With these you should be able to create anything you can imagine.


Parsing:
--------

Uses [englishy parsing](https://github.com/da99/englishy):

    This is a line.
    This line is continued
      here.
    This one has a block:

      Content goes here.

Other stuff that may change.
-----------------------------
### Core Functionality Implementation in Native Language:

One of the harder problems to solve was figuring out the core functionality
that will serve as the building blocks
you use to create programs. Forth inspired me since it shows you how
to implement anything using a long block of memory.  
[This includes if/else statements](http://keithdevens.com/weblog/archive/2005/Jan/24/Thinking-Forth).
Arrays, Hashes, Strings, Classes, etc... They are all there to automate finding 
and storing stuff in a block of memory.


### Scope:

Each scope has a `stack` as a KVI. 

### Content and Logic Integration:

    New default column named, "First".
    Default link *!von to: http://www.mises.org/.
    Default link *!LRC to: http://www.lewrockwell.com/.
    
    A new paragraph, named "Physics", with content:

      I love *!Holoscience!. I check the TPOD
      everyday on *(Thunderbolts.info). I found
      out about the theory over at *!LRC.

    Set key, "styles", to: electric_uni links.
    Link *!...! to: http://www.holoscience.com/.
    Link *(...) to: http://www.thunderbolts.info/.

    A new paragraph, named "Economics":

      Set key, "styles", to: econ links.
      
      Content is:

        I read *!von and *!LRC.

The use of a `values` and `objects` is what makes the above concise and non-repetitive.
In order to avoid the constant use of `dup` and `dip`, I use
implied functions to search for values on the `stack` and `dup` it:

    Add to styles: links.
    Print last of Stack.

The 1st line alters last item in the `objects` stack.
The 2nd line uses the last item in the `values` stack.

### Defining a Procedure:

This is simpler for the masses to understand than to confuse them
with terms like `method` and `function`.

    Create procedure named, "Add_2".
      
      Add 2 to [...]

    Block is:

      2 + first Args

### Matching against non-String, non-Num values:

The last major problem was matching procedures to lines
containing objects more complex than Strings or Nums:

    Add old-list to new-list.
    Name it: new-list.

Here, `old-list` and `new-list` are lists of numbers
that will be added together. The new list will be placed 
on the `values` and `objects` stack.

    [ 1 , 2 , 3 ]
    [ 4 , 5 , 6 ]
    # ---> [ 1, ..., 6 ]

The procedure used has a pattern: 

    Add [WORD] to [WORD]

The pattern is processed into two values: a **regexp** and an **array**.

    1: %r!Add (...) to (...)!
    2: [ [ "Add", "to" ], 2 ]

The line is matched to the first **regexp**. If that does not work, then
it is matched to the **array**.

    Add old-list to new-list.
    --> match regexp: %r!Add (...) to (...)!
    --> match array:  [['Add', 'to'], [obj, obj].size ]

Type checking is done within the procedure:

    Pass if first Arg has non-num keys.
    Pass if second Arg has non-num keys.

### Regular Expressions:

None. Instead, it's the `stack` with simple instructions:

    My text: "Hello. World. How's it hanging?"
    Change every "W" to "w".
    Change every "." to "!".
    Remove first "!".
    Remove text starting with " H" and ending with "?".
    Print last of Objects.

Is the code too verbose? Well, don't blame me. That's how
people like it. Not my fault you are part of the Genius Minority.
