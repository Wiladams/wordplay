
--local scanner = require("lox_lexer")
local scanner = require("lox_scanner")

local function run(str)
    for lexeme in scanner(str) do
        print(lexeme)
    end
end

local function runFile(filename)
end

local function runPrompt()
    while true do
        io.write("> ")
        run(io.read("*l"))
    end
end

local function main(args)
    if #args > 1 then
        return ("usage: lox [scriptname]")
    elseif #args == 1 then
        runFile(args[1])
    else
        runPrompt()
    end

end

main(arg)