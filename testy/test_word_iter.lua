package.path = "../?.lua;"..package.path

local mmap = require("wordplay.mmap")
local octetstream = require("wordplay.octetstream")
local word_iter = require("wordplay.word_iter")

local filename = select(1, ...)
if not filename then 
    print("Usage: luajit test_word_iter.lua <filename>")
    return false, 'no filename specified'
end

local m = mmap(filename)
local ptr = m:getPointer()

local bs = octetstream(ptr, #m)

local function test_word_segmentation()
    for _, word in word_iter(bs) do
        if #word > 1 then
            print(word)
        end
    end
end

test_word_segmentation()

