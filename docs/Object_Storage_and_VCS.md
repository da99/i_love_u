
Version Control for Objects
==================================

You have 3 choices:
* diffs (objects turned to strings, diff saved to db)
* Saving previous and latest version of object.
* Copy of object + patches/diff: similiar to decentralized version control systems.

Each table can have instructions on which objects and version control style to use.
The instructions are written as `i_love_u` code.


Shared vs. Dedicated
===================

* No more than 30 create/delete indexes per table per 30 minutes.
  * 3 times breaking of this guideline: suggestion to move to dedicated.
* No ad-hoc queries for tables more than 500 records.

If these guidelines are not met, you have to learn/think/use indexes and/or more
to dedicated servers.
