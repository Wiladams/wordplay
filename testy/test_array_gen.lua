package.path = "../?.lua;"..package.path

local ffi = require("ffi")
local funk = require("wordplay.funk")()
local cctype = require("wordplay.cctype")

local testStr = "hello"
local testStrSize = ffi.sizeof(ffi.cast("const char *", testStr))
print("testStrSize: ", testStrSize)

local gen = array_gen
local param = {data=ffi.cast("const char *", testStr), size=#testStr, offset=0}
print("param.data type: ", type(param.data), ffi.typeof(param.data))
local state = 0

ffi.cdef[[
struct foo {
    int a;
    int b;
};
]]

--print(ffi.typeof("struct foo[10]"))
--print(ffi.typeof("struct foo[$]",13))
--for i, c in gen, param, state do
--    print(i,string.char(c))
--end

--each(print(ffi.cast("const char *", testStr)))

each(print, ffi.cast("const char *", testStr))