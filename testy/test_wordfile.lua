package.path = "../?.lua;"..package.path

local ffi = require("ffi")

local cctype = require("wordplay.cctype")
local toupper = cctype.toupper
local tolower = cctype.tolower
local ispunct = cctype.ispunct

local mmap = require("mmap")
local binstream = require("wordplay.binstream")

local wordplay = require("wordplay.wordplay")()
--[[
local filter = wordplay.filter
local word_iter = wordplay.word_iter
local trans_item = wordplay.trans_item
local quote_iter = wordplay.quote_iter
--]]

local spairs = require("wordplay.spairs")

local filename = select(1, ...)
if not filename then 
    print("Usage: luajit test_wordfile.lua <filename>")
    return false, 'no filename specified'
end

local m = mmap(filename)
local ptr = m:getPointer()

--print("size: ", #m)
local bs = binstream(ptr, #m)



local function removePunct(item)
    if ispunct(item) then
        return false, item
    end

    return true, item
end

local function transformPunct(item)
    if ispunct(item) then
        return true, string.byte(' ')
    end

    return true, item
end

local function removeShorts(size, item)
    return function(item)
        if #item < size then
            return false, item
        end

        return true,  item
    end
end




local function test_wordlist()
    for word in word_iter(trans_item(toupper, filter(removePunct, bs:octets()))) do
        print(word)
    end
end

local function test_quotes()
    for word in quote_iter(bs:octets()) do

        print(word)
        print("----")
    end
end

local function test_wordcount()
    local counter = 0
    for word in word_iter( filter(removePunct, bs:octets())) do
        counter = counter+1
    end
    print("wc: ", counter)
end

local function test_wordlength()
    local dict = {}
    for word in  word_iter( trans_item(toupper, filter(transformPunct, bs:octets()))) do
        local value = dict[word]
        if not value then
            dict[word] = #word
        end
    end

    -- iterate dictionary in sorted order
    for k,v in spairs(dict, function(t,a,b) return t[b] < t[a] end) do
        print(string.format("    %s = %d,", k,v))
    end
end

local function test_wordfreq()
    local dict = {}
    local longest = 0
    local longestword = nil
    local shortest = math.huge
    local shortestword = nil
    local counter = 0

    -- stream octets
    -- remove punctuation
    -- turn to upper case
    -- turn into words
    -- remove shortest words
    for word in filter(removeShorts(3), word_iter( trans_item(toupper, filter(removePunct, bs:octets())))) do
        counter = counter + 1
        if #word > longest then
            longest = #word
            longestword = word 
        end

        if #word < shortest then
            shortest = #word
            shortestword = word 
        end

        local count = dict[word]
        if not count then
            dict[word] = 1
        else
            dict[word] = count+1
        end
    end

    --print("SORT")
    --table.sort(dict)

    -- print out results
    print("{")
    print(string.format("  wordcount = %d,", counter))
    print(string.format("  {longest = %d, '%s'},", longest, longestword))
    print(string.format("  {shortest = %d, '%s'},", shortest, shortestword))
    print("  words = {")
    for k,v in spairs(dict, function(t,a,b) return t[b] < t[a] end) do
        print(string.format("    %s = %d,", k,v))
    end
    print("  }")
    print("}")
end


--test_quotes()
--test_wordlist()
test_wordcount()
--test_wordfreq()
--test_wordlength()

