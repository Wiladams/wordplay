package.path = "../?.lua;"..package.path

local mmap = require("wordplay.mmap")
local octetstream = require("wordplay.octetstream")
local field_iter = require("wordplay.field_iter")
local funk = require("wordplay.funk")()
local cctype = require("wordplay.cctype")
local ispunct = cctype.ispunct


local function longWord(x) return #x > 1 end
local function isName(x) return x:match("@!") end
local function stripNameMarker(x) return x:sub(3) end
local function notPunct(x) return not ispunct(x:byte()) end
local function notNumber(x) return not tonumber(x) end




local line = "this, is a bunch of fields, in a , line,,,"
print(line)
each(print, enumerate(field_iter(string.byte',', octetstream(line))))

local line = "A,'a little something',in between,O"
print(line)
each(print, enumerate(field_iter(string.byte',', octetstream(line))))

local line = "a\tb\tc\td"
print(line)
each(print, enumerate(field_iter(string.byte'\t', octetstream(line))))

local line = "once|upon|a|time|in|America"
print(line)
each(print, enumerate(field_iter(string.byte'|', octetstream(line))))


