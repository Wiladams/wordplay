
local ffi = require("ffi")
local C = ffi.C 

local cctype = require("wordplay.cctype")
local isspace = cctype.isspace

local exports = {}



--[[
    iterator utilities

]]
function send (...)
    coroutine.yield(...)
end

--[[
    iterator parts
]]
function exports.char_op(op, prod)
    return coroutine.wrap(function()
        for c in prod do
            send(op(c))
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

return exports

