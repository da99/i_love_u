
Disclaimer:
-----------

This abomination no longer being developed.

Check out it's successor: [Factor\_Script](https://github.com/da99/factor_script)

You *can't* use it for anything practical 
right now. 

i\_love\_u
---------

Fall in love with computers all over again.

A scripting language for graphic designers using "design for extremes".

It reads like a subset of English. However, it has dynamic syntax.
So mold it to read like Japanese, Spanish, whatever.


Mastering the subtle art of writing i\_love\_u code.
-------

Get your idiot friends to teach it to you.


Installation and Usage:
-----------------------

    your_shell> npm install i_love_u

    # In your coffeescript code:

    love = require("i_love_u")

    u = new love.i_love_u """
      One is: 1.
      Six is: One + 5.
    """
    u.run()
    vals = (v.value() for v in u.data() ) 
    vals
    
    # --> ["1", 6.0]
    
If/else
------

    u = new love.i_love_u """
      If true:
        One is: 1.
      else:
        Two is: 2.
    """
    u.run()
    vals = (v.value() for v in u.data() ) 
    vals
    
    # --> ["1"]

    
Commercial Break:
-----------------

[British Airways](http://www.youtube.com/watch?v=Yxbgm9Bmkzw)

[The Adventures of Buckaroo Banzai](http://www.youtube.com/watch?feature=player_detailpage&v=8MqJ3iGBdOo#t=24s)

<!-- [Slava Pestov on Factor](http://www.youtube.com/watch?v=f_0QlhYlS8g) -->

<!-- http://www.amazon.com/dp/B00005JKEX/?tag=miniunicom-20 -->


Ending Credits:
--------------

*Written, Produced, and Directed* <br />
by reading, pacing around, and thinking.


Do you still hate computers?
----------------------------

* Use [Squeak](http://www.youtube.com/results?search_query=squeak+etoys&oq=squeak+etoys). 
* Try [learning programming](http://www.khanacademy.org/cs) the traditional way.
* You can also [learn programming the hard way](http://learncodethehardway.org/).


The End
-------

...for now.


