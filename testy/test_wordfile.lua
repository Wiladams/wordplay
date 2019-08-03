package.path = "../?.lua;"..package.path

local ffi = require("ffi")

local cctype = require("wordplay.cctype")
local toupper = cctype.toupper
local tolower = cctype.tolower
local ispunct = cctype.ispunct

local mmap = require("wordplay.mmap")
local binstream = require("wordplay.binstream")
local wordplay = require("wordplay.wordplay")()
local spairs = require("wordplay.spairs")

local filename = select(1, ...)
if not filename then 
    print("Usage: luajit test_wordfile.lua <filename>")
    return false, 'no filename specified'
end

local m = mmap(filename)
local ptr = m:getPointer()

local bs = binstream(ptr, #m)


-- just pass any item straight through
local function passthru(item)
    return item 
end

local function removePunct(item)
    --print("removePunct: ", item)
    if ispunct(item) then
        return nil
    end

    return item
end

local function transformPunct(item)
    if ispunct(item) then
        return string.byte(' ')
    end

    return item
end

local function removeShorts(size, item)
    return function(item)
        if #item < size then
            return nil
        end

        return item
    end
end



local function test_quotes()
    for _,word in quote_iter(bs:octets()) do
        print(word)
        print("----")
    end
end





--[[
    Testing chaining filters together.
    Filters are godd because they themselves
    are iterators, so easily chainable.

    Filters act on a single item at a time.  They can
    transform the item, passthru, or delete.
]]
local function test_filter()
    -- remove punctuation
    -- and convert everything to uppercase
    for _, item in filter(toupper, filter(removePunct, bs:octets())) do
        io.write(string.char(item))
    end
end

local function test_words()
    -- remove punctuation
    -- convert to uppercase
    -- segment base on <SP>

    for _, item in segmenter(' ', filter(toupper, filter(removePunct, bs:octets()))) do
        print(item)
    end
end

local function test_word_count()
    local counter = 0
    for _, item in segmenter(' ', filter(removePunct, bs:octets())) do
        counter = counter+1
    end
    print("wc: ", counter)
end

local function test_wordlength()
    local dict = {}
    for _, word in  segmenter(' ', filter(toupper, filter(removePunct, bs:octets()))) do
        local len = #word
        if not dict[len] then
            dict[len] = 1;
        else
            dict[len] = dict[len] + 1;
        end
        local value = dict[word]
    end

    -- iterate dictionary in sorted order
    print("length   occurences")
    for k,v in spairs(dict, function(t,a,b) return t[b] < t[a] end) do
        print(string.format("%5d  = %d,", k,v))
    end
end

local function test_word_frequency()
    -- remove punctuation
    -- convert to uppercase
    -- segment base on <SP>
    -- increment dictionary
    -- print results

    local words = {}

    for _, item in segmenter(' ', filter(toupper, filter(removePunct, bs:octets()))) do
        if words[item] then
            words[item] = words[item] + 1;
        else
            words[item] = 1;
        end
    end

    for k,v in spairs(words, function(t,a,b) return t[b] < t[a] end) do
        print(string.format("    %s = %d,", k,v))
        --print(k,v)
    end
end

local function test_words_worth()
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
    for _, word in segmenter(' ', filter(toupper, filter(removePunct, bs:octets()))) do
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



--test_filter()
--test_words()
--test_word_count()
--test_wordlength()
--test_word_frequency()
--test_words_worth()

test_quotes()



