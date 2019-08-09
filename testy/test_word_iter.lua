package.path = "../?.lua;"..package.path

local mmap = require("wordplay.mmap")
local octetstream = require("wordplay.octetstream")
local word_iter = require("wordplay.word_iter")
local funk = require("wordplay.funk")()
local cctype = require("wordplay.cctype")
local ispunct = cctype.ispunct

local filename = select(1, ...)
if not filename then 
    print("Usage: luajit test_word_iter.lua <filename>")
    return false, 'no filename specified'
end

local m = mmap(filename)
local ptr = m:getPointer()

local bs = octetstream(ptr, #m)

local function longWord(x) return #x > 1 end
local function isName(x) return x:match("@!") end
local function stripNameMarker(x) return x:sub(3) end
local function notPunct(x) return not ispunct(x:byte()) end
local function notNumber(x) return not tonumber(x) end



local function test_word_segmentation()
    each(print, filter(longWord, word_iter(bs)))
end

local function test_unique_names()
    each(print, unique(map(stripNameMarker, filter(isName, word_iter(bs)))))
end

--test_word_segmentation()
--test_unique_names()

-- unique words
each(print, unique(map(string.upper,filter(notNumber, filter(notPunct, word_iter(bs))))))


