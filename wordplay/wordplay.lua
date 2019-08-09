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




-- iterates things that are quoted
-- can not recover from when quote is too long
-- or if quotes don't book end properly
function exports.quote_iter(srcgen, srcparams, srcstate)
    local bufferSize = 4096
    local buffer = ffi.new("uint8_t[?]", 4096)

    local function quote_gen(params, state)
        local srcgen = params.srcgen;
        local srcparams = params.srcparams;

        local offset = 0;
        local inquote = false
        local c

        while true do
            state, c = srcgen(srcparams, state)
            if not state then
                break;
            end

            if inquote then
                if c == string.byte('"') then
                    --print("QEND")
                    inquote = false
                    local str = ffi.string(buffer, offset)
                    return state, str
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
            return state, str
        end
    end

    return quote_gen, {srcparams = srcparams, srcgen = srcgen}, srcstate
end


--[[
    segmenter
    
    Consume an iterator of bytes, produce an iteration 
    of lua strings.  
    
    Specify a separator byte.
    Do not return empty strings

    Maximum string size is 1024 bytes
 --]]

 function exports.segmenter(sep, gen, params, state)
    if type(sep) == "string" then
        sep = string.byte(sep)
    end

    local bufferSize = 1024
    local buffer = ffi.new("uint8_t[1024]")

    local function segment_gen(params, state)
        local srcgen = params.srcgen
        local srcparams = params.srcparams

        local offset = 0;
        while true do
            state, c = srcgen(srcparams, state)
            if not state then
                break;
            end

            if c ~= sep then
                buffer[offset] = c;
                offset = offset + 1
            else
                -- we've come across the separator
                if offset > 0 then
                    -- if we've already captured some characters,
                    -- then break out
                    break;
                end 

                -- if we got to here
                -- we need to just loop around some more
                -- because we have a blank string
            end
        end

        if offset < 1 then
            return nil;
        end

        local str = ffi.string(buffer, offset)
        return state, str
    end

    return segment_gen, {srcgen = gen, srcparams = params}, state
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

