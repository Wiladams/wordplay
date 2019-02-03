package.path = "../?.lua;"..package.path

local ffi = require("ffi")
local cctype = require("wordplay.cctype")
local toupper = cctype.toupper
local tolower = cctype.tolower

local tokenz = require("wordplay.wordplay")
local word_iter = tokenz.word_iter
local trans_item = tokenz.trans_item

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
    for word in tokenz.word_iter(trans_item(toupper, bs:octets())) do
        print(word)
    end
end

local function test_tolower()
    for word in tokenz.word_iter(trans_item(tolower, bs:octets())) do
        print(word)
    end
end

local function test_segmenter()
    local str = "d:\\repos\\wordplay\\testy"
    local bs = binstream(str, #str, 0)

    for word in tokenz.segmenter('\\', trans_item(toupper,bs:octets())) do
        print(word)
    end
end

local function test_tokenizer()
    local function dohash(str)
        local buffptr = ffi.cast("uint8_t *", str)
        local hashcode = 0;
        for i=0, #str do
            hashcode = hashcode + buffptr[i]
        end
        return hashcode 
    end

    local str = "help help help is on the way way so dont despair despair despair"
    local bs = binstream(str, #str, 0)

    for item in trans_item(dohash, tokenz.word_iter(bs:octets())) do
        print(item)
    end
end

--test_octets()
--test_words()
--test_segmenter()
test_tokenizer();
--test_tolower()
--test_toupper()