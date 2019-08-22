package.path = "../?.lua;"..package.path


local json_common = require("json_common")
local TokenType = json_common.TokenType
local JSONScanner = require("json_scanner")
local JSONVM = require("json_vm")
local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")
local collections = require("wordplay.collections")
local stack = collections.Stack
local funk = require("wordplay.funk")()


local function isArray(tbl)
    return #tbl > 0
end

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
    io.write('\n')
end

local function printTable(level,tbl)

    if isArray(tbl) then
        --print("ISARRAY")
        for _, entry in ipairs(tbl) do
            --each(print, entry)
---[[
            if type(entry) == "table" then
                printTable(level+1, entry)
            else
                each(print, entry)
                --output(level, entry)
            end
--]]
        end
    else
        --each(print, entry)
--[[
        for k, entry in pairs(tbl) do
            --print(k,v)
            if type(entry) == "table" then
                printTable(level+1, entry)
            else
                each(print, entry)
                --output(level, k,entry)
            end
        end
--]]
    end

end


local function jsonToTable(bs, res)
    res = res or {}

    local currentTbl = res
    local currentMoniker
    local tableStack = stack();
    local monikerStack = stack();

    tableStack:push(res)

    for state, token in  JSONVM(bs) do
        --print(token, currentMoniker)
        if token.kind == TokenType.BEGIN_OBJECT then
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
            tableStack:pop()
            currentTbl = tableStack:top()
            currentMoniker = monikerStack:pop()
        elseif token.kind == TokenType.BEGIN_ARRAY then
            local tbl = {}
            if currentMoniker then
                currentTbl[currentMoniker] = tbl
                currentMoniker = nil
            end

            tableStack:push(tbl)
            currentTbl = tbl
        elseif token.kind == TokenType.END_ARRAY then
            tableStack:pop()
            currentTbl = tableStack:top()
        elseif token.kind == TokenType.MONIKER then
            currentMoniker = token.value
            monikerStack:push(currentMoniker)
        elseif token.kind == TokenType.STRING or 
            token.kind == TokenType.NUMBER or 
            token.kind == TokenType['false'] or
            token.kind == TokenType['true'] or
            token.kind == TokenType['null'] then
            if currentMoniker then
                currentTbl[currentMoniker] = token.value
                --print("VALUE SET: ", currentMoniker, currentTbl[currentMoniker])
                monikerStack:pop()
                currentMoniker = nil
            else
                table.insert(currentTbl, token.value)
            end
        else
            --print(token)
        end
    end

    --print("jsonToTable, res: ", res)

    return res
end



local function runFile(filename)
    local m = mmap(filename)
    local ptr = m:getPointer()

    local bs = octetstream(ptr, #m)
    local tbl = jsonToTable(bs)

    --print("runFile, tbl: ", #tbl, tbl)
    --print("tbl[1]: ", tbl[1])
    --print("tbl[1]['master']", tbl[1].master)
    --for k,v in pairs(tbl[1]) do
    --    print(k,v)
    --end
    for _, entry in ipairs(tbl[1]) do
        print(entry)
    end

    --printTable(0, tbl)
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
