
local ffi = require("ffi")

local binstream = require("binstream")


require("funkit")()

local function isspace(c)
	return c == 0x20 or (c >= 0x09 and c<=0x0d)
end


local function string_iter(str)
    return coroutine.create(function()
        for idx=1,#str do
            send(string.sub(str, idx, idx))
        end
    end)
end

local function word_iter(bs)
    local bufferSize = 1024
    local buffer = ffi.new("uint8_t[?]", 1024)

    return coroutine.wrap(function ()
        local offset = 0;
        while true do
            local c, err = bs:readOctet();
            if not c then
                if offset > 0 then
                    local str = ffi.string(buffer, offset)
                    send(str)
                    break;
                end
            end

            if not isspace(c) then
                buffer[offset] = c;
                offset = offset + 1
            else
                local str = ffi.string(buffer, offset)
                send(str)
                offset = 0
            end
        end
    end)
end


local str = "this is the really long string that I will use for testing"
local bs = binstream(str, #str, 0)

for word in word_iter(bs) do
    print(word)
end
