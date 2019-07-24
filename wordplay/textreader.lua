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
    readLine

    Return a single line as a lua string.  A 'line' is delimited
    with 'cr/lf', or 'lf'

    Meaningfully, we don't include the line ending in the string.
]]
local CR = string.byte('\r')
local LF = string.byte('\n')

local function readSingleLine(src)
    if src:isEOF() then
        return nil;
    end

    local starting = src:tell();
    local startPtr = src:getPositionPointer();
    local ending = starting

    local haveCR = false;
    local haveLF = false;

    while not src:isEOF() do
        local c = src:readOctet();
        if haveCR then
            if c == LF then
                haveLF = true;
                break;
            elseif c ~= CR then
                haveCR = false
            end
        else
            if c == CR then
                haveCR = true;
            elseif c == LF then
                haveLF = true;
                break;
            end
        end
    end

    ending = src:tell();
    if haveLF then
        ending = ending - 1;
    end
    if haveCR then
        ending = ending - 1;
    end

    local len = ending - starting
    --print("LEN: ", len)
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