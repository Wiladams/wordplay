--[[
    Test putting funk into a local namespace
]]
package.path = "../?.lua;"..package.path

local ffi = require("ffi")
local namespace = require("wordplay.namespace")
local octetstream = require("wordplay.octetstream")
local cctype = require("wordplay.cctype")
local isalnum = cctype.isalnum

local funk = require("wordplay.funk")
local finq = require("wordplay.finq")
local field_iter = require("wordplay.field_iter")

local localNS = namespace()
finq(localNS)
funk(localNS)

local T_BAR = string.byte('|')
local T_SPACE = string.byte(' ')
local T_COMMA = string.byte(',')

local function test_where()
    local line = "so once upon a time in America there were many animals that roamed across the prairies"
    each(print, where(function(x) return #x > 4 end, field_iter(T_SPACE, octetstream(line))))

    --field_iter(T_BAR, octetstream(line)):where(function(x) return #x > 3 end):each(print)
end

--local function allowNonSpace(c) return isalnum(c) end

local function test_record()
    local recordValues = [[
William,Adams,54
Mubeen,Adams,21
Rahim,Adams,5
Raima,Adams,3
    ]]
    local recordData = {data=ffi.cast("const char *", recordValues), size = #recordValues, cursor=0}

    local columnHeaderValue = "first, last, age"
    local columnHeaderData = {data=ffi.cast("const char *", columnHeaderValue), size = #columnHeaderValue, cursor=0}
    local colHeaders = octetstream(columnHeaderValue)

    each(print, field_iter(T_COMMA, colHeaders))
    --each(print, map(function(x)return string.char(x) end, octetstream(columnHeaderValue):octets()))
end

local function test_take_while()
    local columnHeaderValue = "first, last, age"
    local colHeaders = octetstream(columnHeaderValue)
    each(print, take_while(isalnum, colHeaders:octets()))
end

--test_where()
--test_record()
test_take_while()
