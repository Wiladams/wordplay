package.path = "../?.lua;"..package.path

local octetstream = require("wordplay.octetstream")
local mmap = require("wordplay.mmap")

local scanner = require("xml_scanner")
local xml_common = require("xml_common")
local TokenType = xml_common.TokenType

local filename = arg[1]
if not filename then
    print("usage: luajit xml_rewriter.lua <filename>")
    return false;
end

local m = mmap(filename)
local ptr = m:getPointer()

local bs = octetstream(ptr, #m)

local function elements(gen, params, state)
    --print("elements: ", gen, params, state)

    local function command_gen(params, state)
        local command

        local srcgen = params.srcgen;
        local srcparams = params.srcparams;
        local srcstate = params.srcstate;

        while true do
            local idx, tok = srcgen(srcparams, srcstate)

            if not tok then
                break;
            end

            if tok.Kind == TokenType.IDENTIFIER then
                -- get the next thing which should be a number
                srcstate, tok2 = srcgen(srcparams, srcstate+1)
                if tok2.Kind == TokenType.MINUS or tok2.Kind == TokenType.PLUS then
                    srcstate, tok3 = srcgen(srcparams, srcstate)
                    if tok3.Kind == TokenType.NUMBER then
                        local value = tok3.literal
                        if tok2.Kind == TokenType.MINUS then
                            value = value * -1;
                        end
                        return state+1, {command = tok.lexeme, value = value}
                    end
                elseif tok2.Kind == TokenType.NUMBER then
                    return state+1, {command = tok.lexeme, value = tok2.literal}
                end
            end
        end
    end

    return command_gen, {srcgen = gen, srcparams = params, srcstate=0}, 0
end

for state, cmd in commands(scanner(bs)) do

    
    print(state, cmd.command, cmd.value)
end



