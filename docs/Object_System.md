
Intro
=====
The object system basically consists of:

* Humane lists (holding data), save\_able to the datastore.
* Files containing `i_love_u` code.

Namespacing is used to attach behaviour and protection to data. 

    Merge with "Garage file": okdoki/cars/parking_garage.
    
    My-Summer-Garage is: a new cloned Parking-Garage.
    My-Winter-Garage is: a new cloned Parking-Garage.

    Open all garages.

    *-> or..
    Refer to "Garage file": Open all garages.
    
    *-> or..
    Refer to "Garage file": 
      Open all garages.
    
    For any Car:

      Define turn_on_ignitition:
        
        Turn on ignition.
        ...functionality...

    For My-Car:

      Define clean_car:
        Clean it.
        ...functionality...

      Clean it.
      Turn on ignition.

    Treat My-Spouse as a Car:
      Turn on ignition.


Each object (humane list w/ attached functionality) has a field
named `acts_like` that contains the names of the files that holds
its functionality. When an object is retrieved from the datastore, 
the `acts_like` files are automatically retrieved. They are 
namespaced/interpreted if not already namespaced/interpreted.

Currently, this does not meet Alan Kay's specifications for OOP. 
Hopefully, someone will come along and re-design it or the entire `i_love_u`
arch. the right way.


Saving Objects to Database.
===========================

Data is saved as one set of records. 
Per-object custom functionality 
is saved as a separate set of records. The following
would be two records:

    For My-Car:

      Define clean_car:
        Clean it.
        Import...
        ===================
        ...functionality...

      Define paint_car:
        Paint it: !>WORD<.
        ===================
        Clean it.
        ...other functionality...
   
This relies on defining functions using the `clean slate/import` approach. 
There will be no closures which refer to state, only clean slate functions
with imported from outside environment. There will be no other way to define
functions because it would be too confusing to have closures and clean slate 
functions for non-programmers.


   
Message Passing (The key to inheritance/prototype architecture.)
===============

Each message is an object with properties. Some properties include:

* language of the client and/or user.
* source of message, to deterimine permissions for update or trash.
* file url of origin of message.

Each message can have before/after/override related functions.

Objects can "defer" to a list of "ancestors" that contain data and functions 
(ie mixins). The returned values are always get read-only 
clones of the actual values.
You never get the actual value because that is up to the object.

* Each object that can have decendants will have "before/after init" functions.
* There can be no data initialized before the initialized process. The following
is not allowed:

    class Car
      @price = "1000000"

      def initialize
        ...














