--[[
    Consume an octetstream, read text, using a specified encoding
]]
local ffi = require("ffi")

local TextReader = {}
local TextReader_mt = {
    __index = TextReader;
}

function TextReader.new(self, src)
    if not src then return nil end

    local obj = {
        sourceStream = src
    }
    setmetatable(obj, TextReader_mt)

    return obj
end

--[[
    readSingleLine(src)

    Parameters:
        src - an octetstream positioned at the start of a line

    Return a single line as a lua string.  
    If src isEOF() then nil is returned
    
    A 'line' is delimited either with the combination of 'cr/lf', 
    or a single 'lf'.  
    
    If there are individual 'cr' characters that are not followed
    immediately by 'lf', they will be embedded in the string.

    Meaningfully, we don't include the line ending in the string.
]]
local CR = string.byte('\r')
local LF = string.byte('\n')


local function readSingleLine(src)
    if src:isEOF() then return nil end

    local starting = src:tell();
    local ending = starting
    local startPtr = src:getPositionPointer();

    while not src:isEOF() do
        local c = src:peekOctet();
        if c < 0 then
            break;
        end

        if c == CR then
            c = src:peekOctet(1);
            if c == LF then
                ending = src:tell();
                src:skip(2)
                break;
            end
        elseif c == LF then
            src:skip(1)
            break;
        end

        src:skip(1)
        ending = src:tell()
    end

    local len = ending - starting
    local value = ffi.string(startPtr, len)

    return value;
end

function TextReader.readLine(self)
    return readSingleLine(self.sourceStream)
end

function TextReader.lines(self)
    local function gen_line(param, state)
        local value = readSingleLine(param)
        if not value then
            return nil;
        end
        
        return state + 1, value
    end

    return gen_line, self.sourceStream, 0
end

return TextReader