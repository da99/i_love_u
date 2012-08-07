
humane\_list
============

Combining arrays with kv structures.  It is meant to act the 
way non-programmers (ie humans) expect lists to act (ie usability).

* Default index is 1, not 0.
* This is no `shift` or `unshift`.
* `.pop( 'front' )` and `.push('front', vals)` to attach before first element. 
* `.pop( 'end'  )`  and `.push('end',  vals)` to pop/insert after last element.
* `.front()` and `.end()` instead of `.first()` and `.last()`
  * Why design it this way? Because index positions can be -1, -2.1, etc. 
    Non-programmers would assume `.first()` returned value at index 1, instead of -1.
* Instead of index, you have positions. 
  * Why?! Because non-programmers might confuse keys with indexes.  Think of a 
    book with an index.

Installation and Usage
=====

On your shell:

    npm install humane_list

In your script:

    var hl = require('humane_list');
    var empty   = new hl.Humane_List();
    var w_array = new hl.Humane_List( [1,2,3] );
    var w_obj   = new hl.Humane_List( { one: 1, two: 2, three: 3 } );


Usage: Inserting
=====

    stuff.push( "end", "red" );
    stuff.push( "end", "blue" );
    stuff.end(); 
    // => "blue"
    
Remember, index starts with 1, not 0.

    stuff.alias( 1, "favorite" );
    stuff.alias( "favorite", "fire_color" );
    stuff.at_key( "favorite" );
    // => "red"
    
    stuff.at_key( "fire_color" );
    // => "red"

Usage: Inspect
================

    stuff.has_key( "favorite" );
    // => true

    stuff.positions();
    // => [ 1, 2 ]

    stuff.keys();
    // => [ ['favorite', 'fire_color'], [] ]
    
    stuff.values();
    // => [ 'red', 'blue' ]


Usage: Deleting
=============

    stuff.delete_at( "fire_color");
    stuff.delete_at( 2 ); 
    // This deletes value at index 2.

No shift or unshift.

    stuff.pop('front');
    // => "red"
    
    stuff.push( 'front', "red" );
    // => "red"
    




