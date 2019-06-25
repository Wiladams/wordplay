--[[
    Test out the lexer
    Just run iterator over controlled input
--]]

local ffi = require("ffi")
local lexer = require("lox_lexer")

local lexInput1 = [[
// this is a comment
(( )){} // grouping stuff
!*+-/=<> <= == // operators
]]

local lexInput2 = 'var language = "lox";'



local function test_lexemes(str)
    for lexeme in lexer(str) do
        print(lexeme)
    end
end

local function test_literals()
local text = [[
// This is a string literal
"here is a STRING literal"
// followed by numbers
123
456
123.456
]]
    
    for lexeme in lexer(text) do
        print(lexeme)
    end
end

local function test_identifier()
local text = [[
ID = 1;
c=  "hello, world!"
fun myFunc() {
    while a < 23 {
        b = 23.4
    }
}
]]
    for lexeme in lexer(text) do
        print(lexeme)
    end
end


--test_lexemes(lexInput1)
--test_literals();
test_identifier();
