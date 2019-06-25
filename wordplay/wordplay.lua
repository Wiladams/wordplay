--[[
    Web corpus to play with

    https://corpus.byu.edu/iweb/
--]]

local ffi = require("ffi")
local C = ffi.C 

local cctype = require("wordplay.cctype")
local isspace = cctype.isspace

local exports = {}


--[[
    iterator utilities
    https://www.lua.org/pil/9.2.html
]]
local function send (...)
    coroutine.yield(...)
end


local function receive (prod)
    --print("receive, pulling")
    local status, value = coroutine.resume(prod)

    --print("receive, status: ", status)
    if not status then 
        return nil 
    end
    
    return value
end
--[[
    iterator parts
--]]
--[[
    simple iterator that takes the items coming
    from the input iterator, applies an operation
    and sends the output.
]]
function exports.trans_item(op, prod)
    return coroutine.wrap(function()
        for c in prod do
            send(op(c))
        end
    end)
end

function exports.filter(tformer, prod)
    return coroutine.wrap(function()
        for item in prod do
            local success, value = tformer(item)
            if success then
                send(value)
            end
        end
    end)    
end

-- iterates things that are quoted
-- can not recover from when quote is too long
-- or if quotes don't book end properly
function exports.quote_iter(prod)
    local bufferSize = 4096
    local buffer = ffi.new("uint8_t[?]", 4096)

    return coroutine.wrap(function ()
        local offset = 0;
        local inquote = false

        for c in prod do
            if inquote then
                if c == string.byte('"') then
                    --print("QEND")
                    inquote = false
                    local str = ffi.string(buffer, offset)
                    send(str)
                    offset = 0
                else
                    buffer[offset] = c;
                    offset = offset + 1
                end
            elseif c == string.byte('"') then
                --print("QSTART")
                inquote = true
                offset = 0
            else
                --print("SKIP: ", string.char(c))
            end
        end

        -- trailing edge
        -- no more characters coming in, but we were
        -- working on a word
        if offset > 0 then
            local str = ffi.string(buffer, offset)
            send(str)
        end
    end)
end

--[[
 word_iter
    Consume an iterator of bytes, produce an iteration 
    of lua strings
 --]]

function exports.word_iter(prod)
    local bufferSize = 1024
    local buffer = ffi.new("uint8_t[?]", 1024)

    return coroutine.wrap(function ()
        local offset = 0;
        for c in prod do
            if not isspace(c) then
                buffer[offset] = c;
                offset = offset + 1
            else
                if offset > 0 then -- eliminate blank strings
                local str = ffi.string(buffer, offset)
                send(str)
                end
                offset = 0
            end
        end

        -- trailing edge
        -- no more characters coming in, but we were
        -- working on a word
        if offset > 0 then
            local str = ffi.string(buffer, offset)
            send(str)
        end
    end)
end



--[[
 segmenter
    Consume an iterator of bytes, produce an iteration 
    of lua strings.  Specify a separator byte.
    Do not return empty strings
 --]]

 function exports.segmenter(sep, prod)
    if type(sep) == "string" then
        sep = string.byte(sep)
    end

    local bufferSize = 1024
    local buffer = ffi.new("uint8_t[?]", 1024)

    return coroutine.wrap(function ()
        local offset = 0;
        for c in prod do
            if c ~= sep then
                buffer[offset] = c;
                offset = offset + 1
            else
                local str = ffi.string(buffer, offset)
                send(str)
                offset = 0
            end
        end

        -- trailing edge
        -- no more characters coming in, but we were
        -- working on a word
        if offset > 0 then
            local str = ffi.string(buffer, offset)
            send(str)
        end
    end)
end


-- a special syntax sugar to export all functions to the global table
setmetatable(exports, {
    __call = function(t, override)
        for k, v in pairs(t) do
            if rawget(_G, k) ~= nil then
                local msg = 'function ' .. k .. ' already exists in global scope.'
                if override then
                    rawset(_G, k, v)
                    print('WARNING: ' .. msg .. ' Overwritten.')
                else
                    print('NOTICE: ' .. msg .. ' Skipped.')
                end
            else
                rawset(_G, k, v)
            end
        end
    end,
})


return exports

