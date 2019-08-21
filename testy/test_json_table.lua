package.path = "../?.lua;"..package.path


local json_common = require("json_common")
local TokenType = json_common.TokenType
local JSONScanner = require("json_scanner")
local JSONVM = require("json_vm")
local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")
local collections = require("wordplay.collections")
local stack = collections.Stack


local function jsonToTable(bs, res)
    res = res or {}

    local currentTbl = res
    local currentMoniker
    local tableStack = stack();


    for state, token in  JSONVM(bs) do

        if token.kind == TokenType.BEGIN_OBJECT then
            stackTop = {kind = "object", data = {}}
            output(level, "{\n")
            inObject = true;
        elseif token.kind == TokenType.END_OBJECT then
            output(level-1, "};\n")
            level = level - 1
        elseif token.kind == TokenType.BEGIN_ARRAY then
            output(level, '[\n')
        elseif token.kind == TokenType.END_ARRAY then
            output(level-1, '];\n')
        elseif token.kind == TokenType.MONIKER then
            currentMoniker = token.value
        elseif token.kind == TokenType.STRING then
            if currentMoniker then
                currentTbl[currentMoniker] = token.value
                currentMoniker = nil
            else
                table.insert(currentTbl, token.value)
            end
        elseif token.kind == TokenType.NUMBER then
            if currentMoniker then
                currentTbl[currentMoniker] = token.value
                currentMoniker = nil
            else
                table.insert(currentTbl, token.value)
            end
        else
            print(token)
        end
    end

    return res
end

local function runFile(filename)
    local m = mmap(filename)
    local ptr = m:getPointer()

    local bs = octetstream(ptr, #m)
    return jsonToTable(bs)
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
