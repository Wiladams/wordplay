package.path = "../?.lua;"..package.path


local json_common = require("json_common")
local TokenType = json_common.TokenType
local JSONScanner = require("json_scanner")
local JSONVM = require("json_vm")
local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")

local function indent(level)
    local nspaces = level * 4;
    if nspaces < 1 then return end

    for i=1,nspaces do
        io.write(' ')
    end
end

local function output(level, ...)
    indent(level)
    io.write(...)
end

local function run(bs)
    local level = 0

    for state, token in  JSONVM(bs) do

        if token.kind == TokenType.BEGIN_OBJECT then
            output(level, "{\n")
            level = level + 1
        elseif token.kind == TokenType.END_OBJECT then
            output(level-1, "};\n")
            level = level - 1
        elseif token.kind == TokenType.BEGIN_ARRAY then
            output(level, '[\n')
        elseif token.kind == TokenType.END_ARRAY then
            output(level-1, '];\n')
        elseif token.kind == TokenType.STRING then
            io.write(string.format("\"%s\";\n", token.value))
        elseif token.kind == TokenType.MONIKER then
            if token.value:match('-') then
                output(level, string.format("['%s'] = ", token.value))
            else
                output(level, string.format("%s = ", token.value))
            end
        elseif token.kind == TokenType.NUMBER then
            output(level, string.format("%d;",token.value))
        elseif token.kind == TokenType.null then
            output(level, "'NULL';")
        elseif token.kind == TokenType['true'] then
            io.write("true")
        elseif token.kind == TokenType['false'] then
            io.write('false')
        else
            print(token)
        end
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
