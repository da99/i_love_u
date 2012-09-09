
Storage
=======

All nouns are stored as a single documents using hstore on postgresql.

Indexs and Query
=====

`i_love_u` provides an abstraction layer to write indexs for tables.
The user will never have full or direct access to index, schema, query,
or table creation.

Version Control for Nouns
==================================

`i_love_u` provides a set of librarys for very common version-control
styles. Anything beyond this would require the user to design their 
own version-control style.

Your choices:
* diffs (nouns turned to strings, diff saved to db)
* Saving previous and latest version of the noun.
* Copy of noun + patches/diff: similiar to decentralized version control systems.
* Design your own using `i_love_u`

Each table can have instructions on which nouns and version control style to use.
The instructions are written as `i_love_u` code.


Shared vs. Dedicated
===================

* No more than 30 create/delete indexes per table per 30 minutes.
  * 3 times breaking of this guideline: suggestion to move to dedicated.
* No ad-hoc queries for tables more than 500 records.
* Databases more than 100 gb require a dedicated server.

If these guidelines are not met, you have to learn/think/use indexes and/or more
to dedicated servers.
