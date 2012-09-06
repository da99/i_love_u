
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
its functionality.  

Currently, this does not meet Alan Kay's specifications for OOP. 
Hopefully, someone will come along and re-design it or the entire `i_love_u`
arch. the right way.



