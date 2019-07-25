package.path = "../?.lua;"..package.path

local octetstream = require("wordplay.octetstream")
local textreader = require("wordplay.textreader")

local ostream = octetstream("Hello Stream!!\r\nThis is a new line\nAnd so is this one\r\r\r\nAnd finally this one")

local function test_readLine()
    local tr = textreader:new(ostream)
    while true do
        local line = tr:readLine()
        if not line then 
            break;
        end

        print(#line, line)
    end
end

local function test_lines()
    local tr = textreader:new(ostream)

    for _, line in tr:lines() do 
        print(_, line)
    end
end

test_readLine();
--test_lines();