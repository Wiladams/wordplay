

local JSONScanner = require("json_scanner")
local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")


local function run(bs)
    local xs = JSONScanner:new(bs)
    for state, lexeme in xs:tokens() do
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
        return ("usage: luajit json_repl.lua [scriptname]")
    elseif #args == 1 then
        runFile(args[1])
    else
        runPrompt()
    end

end

main(arg)
