

local JSONScanner = require("json_scanner")
local JSONVM = require("json_vm")
local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")


local function run(bs)
    --for state, token in  JSONVM(bs) do
    --    print(state, token)
    --end

    local scanner = JSONScanner:new(bs)
    for state, tok in scanner:tokens() do
        print(state, tok)
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
