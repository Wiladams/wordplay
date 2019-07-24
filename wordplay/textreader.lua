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

function TextReader.readLine(self)
    if self.sourceStream:isEOF() then
        return nil;
    end

    local starting = self.sourceStream:tell();
    local startPtr = self.sourceStream:getPositionPointer();
    local ending = starting

    local haveCR = false;
    local haveLF = false;

    while not self.sourceStream:isEOF() do
        local c = self.sourceStream:readOctet();
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

    ending = self.sourceStream:tell();
    if haveLF then
        ending = ending - 1;
    end
    if haveCR then
        ending = ending - 1;
    end

    local len = ending - starting
    print("LEN: ", len)
    local value = ffi.string(startPtr, len)

    return value;
end

return TextReader