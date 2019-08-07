# wordplay
a place to play with words

octetstream - A streaming interface which delivers octets (8-bit) one at a time, or in buffers.  Has an iterator.  This is a base for building up other stream types.  It has a peek() feature, and getPositionPointer, which allows you go get a pointer as a particular position.

funk - some functional programming stuff using iterators
This is fundamentally a recreation of luafun 
(https://luafun.github.io/) in a codebase that will hopefully be more active.

The luafun code was not copied, so not all function aliases are implemented, and the usage of error() and assert() have been eliminated, preferring graceful degradation to outright crashing of the application.

Functions Implemented
---------------------

wrap
iter
each
index
indexes
filter
grep
partition
foldl, reduce
length
isNullIterator
isPrefixOf
all
any
sum
product
extentBy
minimum
maximum
totable
tomap
map
enumerate
intersperse
zip
cycle
chain
range
duplicate
tabulate
zeroes
ones
rands
nth
head
tail
take_n
take
drop_n

Not Yet Implemented (NYI)
drop_while
drop
split




cctype - some common character categorization functions

enum - convenience two way dictionary


textreader - can read 'lines' based on common end of line delimeters

wordplay - some experiments in iterators


The test directory 

There are some experiments in scanners here.  They leverage the octetstream mostly.

gcode - gcode_repl, gcode_rewriter, gcode_scanner

lox - lox_scanner, lox_lexer, lox_bnf

mmap - memory mapped file handling

spairs - sorting dictionary


Resources
---------

Sample files

u_ex171118-sample.txt   https://www.site-logfile-explorer.com/logfile-samples/iis.aspx
