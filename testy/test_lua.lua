
local function createSet(str)
    local bytes = {string.byte(str,1,#str)}
    local res = {}
    for i=1,#str do
        res[bytes[i]] = true
    end

    return res
end

local function test_bytearray()
    print(string.byte("\r\n\t",1,2,3))
end

local escapeChars = createSet('/\\"bfnrtu')

for k,v in pairs(escapeChars) do
    print(k,v)
end
