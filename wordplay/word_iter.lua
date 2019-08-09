local ffi = require("ffi")
local cctype = require("wordplay.cctype")
local isspace = cctype.isspace

--[[
 word_iter
    Consume an iterator of bytes, produce an iteration 
    of lua strings.

    This is a pure functional iterator, which means it does 
    not cause side effects on the data source, and is thus
    suitable for things like splits, chains, cycles, and the like
 --]]
local function segment_iter_gen(param, state)
    -- check if end of data
    if param.size - state < 1 then
        return nil;
    end


    -- get rid of leading spaces
    -- while checking for end of data
    while param.size - state >= 1 do
        if isspace(param.data[state]) then
            state = state + 1
        else
            break;
        end
    end

    -- check for end of data again
    -- check if end of data
    if param.size - state < 1 then
        return nil;
    end

    -- mark the beginning of the non-space
    -- and start consuming until we hit a space
    local starting = state
    local startPtr = param.data + state

    while param.size - state >= 1 do
        if isspace(param.data[state]) then
            break;
        end

        state = state + 1
    end

    -- figure out how long the string is
    local len = state - starting
    
    -- if zero length, we've run into the end
    if len == 0 then
        return nil
    end

    local value = ffi.string(startPtr, len)

    return state, value
end

function word_iter(bs)
    return segment_iter_gen, {data=bs.data, size=bs.size, delimeter=string.byte(' ')}, bs:tell()
end

return word_iter