package.path = "../?.lua;"..package.path

local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")

local json_common = require("json_common")
local TokenType = json_common.TokenType
local JSONVM = require("json_vm")
local collections = require("wordplay.collections")
local stack = collections.Stack
local inspect = require("inspect")

--[[
    jsonToTable

    Convert a stream of json to a lua table
]]
local function jsonToTable(bs, res)
    res = res or {}

    local currentTbl = res
    local currentMoniker
    local tableStack = stack();
    local monikerStack = stack();

    tableStack:push(res)

    for state, token in  JSONVM(bs) do
        if token.kind == TokenType.BEGIN_OBJECT then
            --print("BEGIN_OBJECT: ", currentMoniker)
            local tbl = {}
            if currentMoniker then
                currentTbl[currentMoniker] = tbl
                currentMoniker = nil
            else
                table.insert(currentTbl, tbl)
            end

            currentTbl = tbl
            tableStack:push(tbl)
        elseif token.kind == TokenType.END_OBJECT then
            --print("END_OBJECT")
            tableStack:pop()
            currentTbl = tableStack:top()
            --currentMoniker = monikerStack:pop()
        elseif token.kind == TokenType.BEGIN_ARRAY then
            --print("BEGIN_ARRAY: ", currentMoniker)
            local tbl = {}
            if currentMoniker then
                currentTbl[currentMoniker] = tbl
                currentMoniker = nil
            else
                table.insert(currentTbl, tbl)
            end

            currentTbl = tbl
            tableStack:push(tbl)
        elseif token.kind == TokenType.END_ARRAY then
            --print("END_ARRAY: ", currentMoniker)
            tableStack:pop()
            currentTbl = tableStack:top()
            currentMoniker = monikerStack:pop()
        elseif token.kind == TokenType.MONIKER then
            --print("MONIKER: ", token.value)
            currentMoniker = token.value
            monikerStack:push(currentMoniker)
        elseif token.kind == TokenType.STRING or 
            token.kind == TokenType.NUMBER or 
            token.kind == TokenType['false'] or
            token.kind == TokenType['true'] or
            token.kind == TokenType['null'] then
            if currentMoniker then
                currentTbl[currentMoniker] = token.value
                monikerStack:pop()
                currentMoniker = nil
            else
                table.insert(currentTbl, token.value)
            end
        else
            --print(token)
        end
    end

    return res
end



local function runFile(filename)
    local m = mmap(filename)
    local ptr = m:getPointer()

    local bs = octetstream(ptr, #m)
    local tbl = jsonToTable(bs)


    print(inspect(tbl[1]))
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
