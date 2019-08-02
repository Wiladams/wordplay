
--local scanner = require("lox_lexer")
local XmlScanner = require("xml_scanner")
local octetstream = require("wordplay.octetstream")
local mmap = require("mmap")


local function run(bs)
    local xs = XmlScanner:new(bs)
    for state, lexeme in xs:tokens() do
        -- if we want to convert comments to parenthesized
        -- ones
        --[[
        if lexeme.Kind == 40  then  -- comment
            print(string.format("(%s)",lexeme.lexeme))
        end
        --]]
        
        print(state, lexeme)
    end
end

local function runFile(filename)
    local m = mmap(filename)
    local ptr = m:getPointer()

    local bs = octetstream(ptr, #m)
    run(bs)
end

local function runPrompt()
    while true do
        io.write("> ")
        run(octetstream(io.read("*l")))
    end
end

local function main(args)
    if #args > 1 then
        return ("usage: luajit xml_repl.lua [scriptname]")
    elseif #args == 1 then
        runFile(args[1])
    else
        runPrompt()
    end

end

main(arg)
