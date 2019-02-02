package.path = "../?.lua;"..package.path

local cctype = require("wordplay.cctype")
local toupper = cctype.toupper
local tolower = cctype.tolower

local tokenz = require("wordplay.wordtokenizer")
local word_iter = tokenz.word_iter
local char_op = tokenz.char_op

local binstream = require("wordplay.binstream")

local str = "this is the really long string that I will use for testing"
local bs = binstream(str, #str, 0)

local function test_octets()
    for c in bs:octets() do
        print (c, string.char(c))
    end
end

local function test_words()
    for word in tokenz.word_iter(bs:octets()) do
    print(word)
end
end

local function test_toupper()
    for word in tokenz.word_iter(char_op(toupper, bs:octets())) do
        print(word)
    end
end

local function test_tolower()
    for word in tokenz.word_iter(char_op(tolower, bs:octets())) do
        print(word)
    end
end

--test_octets()
--test_words()
test_tolower()
--test_toupper()