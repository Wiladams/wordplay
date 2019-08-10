# wordplay
a place to play with words

octetstream - A streaming interface which delivers octets (8-bit) one at a time, or in buffers.  Has an iterator.  This is a base for building up other stream types.  It has a peek() feature, and getPositionPointer, which allows you go get a pointer as a particular position.

funk 
====
Some functional programming stuff using iterators.  This is fundamentally a recreation of luafun (https://luafun.github.io/) in a codebase that will hopefully be more active.

The luafun code was not copied, so not all function aliases are implemented, and the usage of error() and assert() have been eliminated, preferring graceful degradation to outright crashing of the application.

Functions Implemented
---------------------

helpers
-------
* wrap
* iter

* each
* index
* indexes
* filter
* grep
* partition
* foldl, reduce
* length
* isNullIterator
* isPrefixOf
* all               -- return true if all iterated items are true
* any               -- return true if at least one iterated item is true
* sum               -- return a summation of numeric items
* product           -- return the product of numeric items
* extentBy
* minimum           -- return iterated item with lowest value
* maximum           -- return iterated item with highest value
* totable           -- put iterated items into a table (array)
* tomap             -- put iterated items into a table (dictionary)
* map               -- transform individual items
* enumerate         -- pair iterated values with a numeric ordinal value
* intersperse
* zip               -- combine two or more iterators alternating items
* cycle             -- repeat a sequence of n iterator 
* chain         -- chain 2 or more iterators sequentially
* range         -- return a numeric range of items
* duplicate
* tabulate
* zeroes        -- inifite 0s
* ones          -- infinite 1s
* rands         -- inifinite random numbers
* nth           -- start iteration after the 'nth' has passed
* head          -- take first item of iteration
* tail          -- take last item of iteration
* take_n        -- take 'n' number of items from iteration
* take_while    -- take items while predicate is true
* take          -- take 'n' or predicate
* drop_n
* drop_while
* drop
* split

Some Extras to go with funk
* field_iter - iterate delimited fields
* word_iter - iterate space separated words




cctype - some common ascii character categorization functions.  These functions work on byte values.

* isalnum
* isalpha
* isascii
* isbyte
* iscntrl
* isdigit
* isgraph
* islower
* isprint
* ispunct
* isspace
* isupper
* isxdigit
* tolower
* toupper

New
---

* unique


enum - convenience two way dictionary

mmap - memory mapped file handling

textreader - can read 'lines' based on common end of line delimeters (CR/LF, LF)

wordplay - some experiments in iterators


The test directory 

There are some experiments in scanners here.  They leverage the octetstream mostly.

gcode - gcode_repl, gcode_rewriter, gcode_scanner

lox - lox_scanner, lox_lexer, lox_bnf

spairs - sorting dictionary


Resources
---------

Sample files

u_ex171118-sample.txt   https://www.site-logfile-explorer.com/logfile-samples/iis.aspx

w_spok_1998.txt
