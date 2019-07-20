local octetstream = require("wordplay.octetstream")
local mmap = require("mmap")

local scanner = require("gcode_scanner")
local gcode = require("gcode")
local TokenType = gcode.TokenType

local filename = arg[1]
if not filename then
    print("usage: luajit gcode_rewriter.lua <filename>")
    return false;
end

local m = mmap(filename)
local ptr = m:getPointer()

local bs = octetstream(ptr, #m)


local command

for state, lexeme in scanner(bs) do
    if lexeme.Kind == 
    -- if we want to convert comments to parenthesized
    -- ones
    --[[
    if lexeme.Kind == 40  then  -- comment
        print(string.format("(%s)",lexeme.lexeme))
    end
    --]]
    
    print(state, lexeme)
end



